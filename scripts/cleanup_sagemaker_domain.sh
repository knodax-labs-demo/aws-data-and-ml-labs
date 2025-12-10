#!/usr/bin/env bash
#
# cleanup_sagemaker_domain.sh
#
# Deleting a SageMaker Space may take some time, as the operation is asynchronous.
# To speed up the cleanup process, consider deleting the Space directly from the console.
#
# Deletes:
#   - All SageMaker Spaces (and their Apps) in a Domain
#   - All User Profiles in a Domain
#   - The SageMaker Domain itself
#
# Usage:
#   ./cleanup_sagemaker_domain.sh                 # auto-detect first domain
#   ./cleanup_sagemaker_domain.sh <DOMAIN_ID>     # delete specific domain
#
# Requirements:
#   - AWS CLI configured (aws configure)
#   - jq installed (for JSON parsing)

set -euo pipefail

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"

echo "=== SageMaker Domain Cleanup Script ==="
echo "Using region: $REGION"

# 1. Resolve Domain ID
if [ $# -ge 1 ]; then
  DOMAIN_ID="$1"
  echo "Using DOMAIN_ID from argument: $DOMAIN_ID"
else
  echo "No DOMAIN_ID provided, attempting to auto-detect the first domain..."
  DOMAIN_ID=$(aws sagemaker list-domains --region "$REGION" --query "Domains[0].DomainId" --output text)

  if [ "$DOMAIN_ID" = "None" ] || [ -z "$DOMAIN_ID" ]; then
    echo "No SageMaker Domains found in this account/region."
    exit 0
  fi

  echo "Auto-detected DOMAIN_ID: $DOMAIN_ID"
fi

echo
echo "WARNING: This will delete:"
echo "  - All Spaces (and their Apps) in domain: $DOMAIN_ID"
echo "  - All User Profiles in domain: $DOMAIN_ID"
echo "  - The Domain itself (HomeEfsFileSystem = Delete)"
echo
read -p "Type 'DELETE' to continue: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
  echo "Aborted by user."
  exit 1
fi

############################################
# Helper: delete all Apps for a Space + wait
############################################
delete_apps_for_space() {
  local domain_id="$1"
  local space_name="$2"

  echo "Listing apps for space: $space_name"

  while true; do
    APPS_JSON=$(aws sagemaker list-apps \
      --region "$REGION" \
      --domain-id-equals "$domain_id" \
      --space-name-equals "$space_name")

    APP_PAIRS=$(echo "$APPS_JSON" | jq -r '.Apps[]? | "\(.AppType) \(.AppName) \(.Status)"')

    if [ -z "$APP_PAIRS" ]; then
      echo "No apps remaining for space: $space_name"
      break
    fi

    echo "Apps still present for space $space_name:"
 echo "$APP_PAIRS"

    echo "$APP_PAIRS" | while read -r APP_TYPE APP_NAME APP_STATUS; do
      if [ -z "$APP_TYPE" ] || [ -z "$APP_NAME" ]; then
        continue
      fi

      if [ "$APP_STATUS" = "Deleted" ]; then
        echo "  App already in Deleted status: type=$APP_TYPE, name=$APP_NAME"
        continue
      fi

      echo "  Deleting app: type=$APP_TYPE, name=$APP_NAME, status=$APP_STATUS"
      set +e
      aws sagemaker delete-app \
        --region "$REGION" \
        --domain-id "$domain_id" \
        --space-name "$space_name" \
        --app-type "$APP_TYPE" \
        --app-name "$APP_NAME" >/dev/null 2>&1
      RC=$?
      set -e
      if [ $RC -ne 0 ]; then
        echo "    (ignore-if-not-found) delete-app returned code $RC for $APP_TYPE/$APP_NAME"
      fi
    done

    echo "Waiting for apps to be fully deleted..."
    sleep 10
  done
}

#########################################################
# Helper: delete all User Profiles for a domain + wait
#########################################################
delete_user_profiles_for_domain() {
  local domain_id="$1"

  echo
echo "=== Deleting User Profiles for domain: $domain_id ==="

  while true; do
    UPS_JSON=$(aws sagemaker list-user-profiles \
      --region "$REGION" \
      --domain-id-equals "$domain_id")

    UP_NAMES=$(echo "$UPS_JSON" | jq -r '.UserProfiles[].UserProfileName // empty')

    if [ -z "$UP_NAMES" ]; then
      echo "No user profiles remaining for domain: $domain_id"
      break
    fi

    echo "User profiles still present:"
    echo "$UP_NAMES"

    echo "$UP_NAMES" | while read -r UP_NAME; do
      if [ -z "$UP_NAME" ]; then
        continue
      fi
      echo "  Deleting user profile: $UP_NAME"
      set +e
      aws sagemaker delete-user-profile \
        --region "$REGION" \
        --domain-id "$domain_id" \
        --user-profile-name "$UP_NAME" >/dev/null 2>&1
      RC=$?
      set -e
      if [ $RC -ne 0 ]; then
        echo "    (ignore-if-not-found) delete-user-profile returned code $RC for $UP_NAME"
      fi
    done

    echo "Waiting for user profiles to be fully deleted..."
    sleep 10
  done
}

##########################################
# 2. Delete Spaces (and their Apps)
##########################################
echo
echo "=== Deleting Spaces (and Apps) for domain: $DOMAIN_ID ==="

SPACES_JSON=$(aws sagemaker list-spaces --region "$REGION" --domain-id "$DOMAIN_ID")
SPACE_NAMES=$(echo "$SPACES_JSON" | jq -r '.Spaces[].SpaceName // empty')

if [ -z "$SPACE_NAMES" ]; then
  echo "No spaces found."
else
  echo "$SPACE_NAMES" | while read -r SPACE_NAME; do
    if [ -n "$SPACE_NAME" ]; then
      echo
      echo "---- Processing space: $SPACE_NAME ----"

      # 2a. Delete apps and wait until gone
      delete_apps_for_space "$DOMAIN_ID" "$SPACE_NAME"

      # 2b. Delete the space itself
      echo "Deleting space: $SPACE_NAME"
      aws sagemaker delete-space \
        --region "$REGION" \
        --domain-id "$DOMAIN_ID" \
        --space-name "$SPACE_NAME"
    fi
  done
fi

##########################################
# 3. Delete all User Profiles (with wait)
##########################################
delete_user_profiles_for_domain "$DOMAIN_ID"

##########################################
# 4. Delete the Domain
##########################################
echo
echo "=== Deleting Domain: $DOMAIN_ID ==="
echo "Using retention-policy: {\"HomeEfsFileSystem\": \"Delete\"}"

aws sagemaker delete-domain \
  --region "$REGION" \
  --domain-id "$DOMAIN_ID" \
  --retention-policy "{\"HomeEfsFileSystem\": \"Delete\"}"

echo
echo "=== Cleanup complete. Domain $DOMAIN_ID has been deleted. ==="

