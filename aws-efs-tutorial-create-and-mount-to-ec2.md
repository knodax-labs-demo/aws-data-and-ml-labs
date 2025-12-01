# **AWS EFS Tutorial: Create and Mount Amazon EFS to EC2 (Step-by-Step Hands-On Lab)**

🎥 **YouTube Tutorial:**  
https://youtu.be/W4DiqtLB7HM

Here is a **clean, accurate, EFS-specific cost warning** rewritten for your AWS EFS Tutorial:

---

> ⚠️ **AWS Cost Warning**
>
> This hands-on lab uses **Amazon EFS**, **Amazon EC2**, and **Amazon VPC** networking components, which may incur small charges in your AWS account—especially if the EFS file system remains active.
>
> To minimize costs:
>
> * **Delete the EFS file system** immediately after completing the lab.
> * **Stop or terminate the EC2 instance** when not in use.
> * Remove any associated **mount targets** or **security groups** created for the lab.
> * Use smaller EC2 instance types (Free Tier eligible) whenever possible.
> * Set an **AWS Budget** (recommended: $1–$5) with email alerts.
>
> Always clean up storage and compute resources after finishing the exercise.


## **Objective**

In this hands-on lab, you will create an **Amazon Elastic File System (EFS)** and mount it to an **Amazon EC2** instance.
This shared POSIX file system is ideal for ML workloads requiring **multi-instance access**, **shared scripts**, and **collaborative storage**.

You will complete the following tasks:

1. Create an Amazon EFS file system
2. Launch an EC2 instance and attach EFS during setup
3. Install the NFS client
4. Mount the file system (if not auto-mounted)
5. Verify shared file access

---

## **Step 1: Create an Amazon EFS File System**

### **1.1 Navigate to Amazon EFS Console**

👉 [https://console.aws.amazon.com/efs](https://console.aws.amazon.com/efs)

### **1.2 Create a New File System**

* Click **Create file system**
* Name: **ml-efs-lab**
* Choose the same **VPC** as your EC2 instance
* Leave defaults for:

  * Availability and durability
  * Lifecycle management
  * Performance settings
* Click **Create file system**

---

## **Step 2: Launch an EC2 Instance with EFS Attached**

### **2.1 Launch EC2 Instance**

* Use **Amazon Linux 2023** (Free Tier eligible)
* Select the same **VPC and subnet** as the EFS file system
* In **File systems**, click **Add shared file system**

  * Select **ml-efs-lab**
  * Set **mount point:** `/mnt/efs`

### **2.2 Security Group Configuration**

* EFS uses **NFS port 2049**
* Ensure EC2 outbound rules allow traffic to the **EFS security group**

### **2.3 Connect to EC2**

Use **EC2 Instance Connect** (no key pair needed).

---

## **Step 3: Install NFS Client on EC2**

Run the following command:

```bash
sudo yum install -y amazon-efs-utils
```

(Already installed on some Amazon Linux versions.)

---

## **Step 4: Mount EFS (If Not Auto-Mounted)**

If the EFS was not mounted automatically, run:

```bash
sudo mount -t efs fs-xxxxxx:/ /mnt/efs
```

Replace **fs-xxxxxx** with your EFS file system ID.

---

## **Step 5: Verify Shared File Access**

Switch to root:

```bash
sudo su
```

Create a test file:

```bash
echo "Hello from EFS" > /mnt/efs/test.txt
```

Verify:

```bash
ls -l /mnt/efs
```

You should see:

```
test.txt
```

---

## **Summary**

You have successfully:

* Created an **EFS** file system
* Mounted it to an **EC2 instance**
* Created and verified shared files

EFS is essential in ML workloads requiring:

| ML Use Case             | Why EFS Helps                          |
| ----------------------- | -------------------------------------- |
| Distributed training    | Multiple EC2 nodes access same dataset |
| Central shared scripts  | All nodes read/write to same location  |
| Checkpoints & artifacts | Persisted across compute sessions      |

