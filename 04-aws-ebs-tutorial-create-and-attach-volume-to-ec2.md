# **AWS EBS Tutorial: Create and Attach an EBS Volume to EC2 (Step-by-Step Hands-On)**

🎥 **YouTube Tutorial:**  
https://youtu.be/W4DiqtLB7HM

Here is the **AWS EBS–specific cost warning**, rewritten to match your style and formatting:

---

> ⚠️ **AWS Cost Warning**
>
> This hands-on lab uses **Amazon EBS** and **Amazon EC2**, which may incur charges in your AWS account—especially if the EBS volume remains allocated after the lab.
>
> To minimize costs:
>
> * **Delete the EBS volume** immediately after completing the lab.
> * **Stop or terminate the EC2 instance** when not in use.
> * Remove any additional **snapshots** you may have created.
> * Use Free Tier–eligible EC2 instance types whenever possible.
> * Set an **AWS Budget** (recommended: $1–$5) with email alerts.
>
> Always clean up block storage and compute resources when you finish the exercise.


## **Objective**

In this lab, you will:

1. Create an Amazon **Elastic Block Store (EBS)** volume
2. Attach the EBS volume to an EC2 instance
3. Format the volume
4. Mount it to a directory
5. Persist the mount across reboots

EBS provides **high-performance block storage**, ideal for ML notebooks, training scratch space, and low-latency workloads.

---

## **Step 1: Create an EBS Volume**

### **1.1 Navigate to the EC2 Console**

👉 [https://console.aws.amazon.com/ec2](https://console.aws.amazon.com/ec2)

### **1.2 Create Volume**

* Click **Elastic Block Store → Volumes**
* Click **Create volume**
* Type: **gp3** (recommended)
* Size: **8–20 GiB** (Free Tier eligible up to 30 GiB/month)
* AZ: Choose the **same Availability Zone** as your EC2 instance
  *(EBS volumes **must** match the EC2 instance AZ)*

Click **Create volume**

---

## **Step 2: Attach the EBS Volume to EC2**

### **2.1 Select the Volume**

* Choose the volume you created
* Click **Actions → Attach volume**

### **2.2 Select Instance**

Choose your EC2 instance
Use the default device name (e.g., `/dev/xvdf`)

Click **Attach**

---

## **Step 3: Connect to the EC2 Instance**

Use **EC2 Instance Connect**.

---

## **Step 4: Format the EBS Volume**

Check block devices:

```bash
lsblk
```

You will see something like:

```
xvdf   8:80   0   20G  0 disk
```

Format the volume:

```bash
sudo mkfs -t xfs /dev/xvdf
```

---

## **Step 5: Mount the EBS Volume**

Create a mount directory:

```bash
sudo mkdir /mnt/ebs
```

Mount the volume:

```bash
sudo mount /dev/xvdf /mnt/ebs
```

Verify:

```bash
df -h
```

---

## **Step 6: Test the Storage**

Write a file:

```bash
echo "Hello from EBS" | sudo tee /mnt/ebs/test.txt
```

List files:

```bash
ls -l /mnt/ebs
```

---

## **Step 7: Make the Mount Persistent (Optional but Recommended)**

Open the fstab file:

```bash
sudo nano /etc/fstab
```

Add the following line:

```
/dev/xvdf  /mnt/ebs  xfs  defaults,nofail  0  2
```

Save & exit.

Test:

```bash
sudo mount -a
```

---

## **Summary**

You successfully:

* Created an **EBS volume**
* Attached and formatted it
* Mounted it to your EC2 instance
* Enabled persistent mounting

EBS is ideal for:

| ML Use Case               | Why EBS Helps                  |
| ------------------------- | ------------------------------ |
| Notebook storage          | Persistent, fast block storage |
| Training cache            | Low-latency operations         |
| High-throughput workloads | Consistent IOPS performance    |


