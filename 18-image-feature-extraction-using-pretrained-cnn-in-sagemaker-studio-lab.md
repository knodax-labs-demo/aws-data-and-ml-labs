
# **Hands-on Lab: Extract Image Features Using Pre-Trained CNN Models in SageMaker Studio Lab**

🎥 **YouTube Tutorial:**  
https://youtu.be/7K-gnWlgAt8

---

## ⚠️ **Cost & Resource Usage Warning (SageMaker Studio Lab)**

Although **SageMaker Studio Lab is free**, resources are limited:

* GPU runtime hours are capped per week for free-tier users.
* Idle sessions may auto-stop, causing loss of unsaved work.
* Large models (ResNet50, VGG, EfficientNet) require more VRAM—CPU mode works but is slower.
* Avoid uploading excessively large image datasets; Studio Lab storage is limited.
* Always save extracted features (`.csv`, `.npy`) externally (GitHub, S3, local download).

Use small test images and keep sessions short to avoid interruptions.

---

This hands-on lab walks you through extracting image features (embeddings) using a pre-trained convolutional neural network (CNN) such as **ResNet50**. You will run this workflow inside **SageMaker Studio Lab**, which provides a managed notebook environment.

These deep features are widely used in machine learning tasks such as clustering, retrieval, and transfer learning.

---

# **Step 1: Launch SageMaker Studio Lab and Create a New Notebook**

1. Visit **[https://studiolab.sagemaker.aws/](https://studiolab.sagemaker.aws/)**
2. Sign in and create a **Python 3** notebook.
3. (Optional but recommended) Switch runtime to GPU when available.

---

# **Step 2: Install Required Libraries**

Run this cell:

```python
# Install dependencies
!pip install torch torchvision numpy pandas pillow
```

---

# **Step 3: Import Required Libraries**

```python
import torch
from torchvision import models, transforms
from PIL import Image
import numpy as np
import pandas as pd
import os
```

---

# **Step 4: Load a Pre-trained CNN Model (ResNet50)**

```python
# Load pre-trained ResNet50 model
model = models.resnet50(pretrained=True)
model.eval()  # evaluation mode
```

ResNet50 outputs a **2048-dimensional feature vector** from its penultimate layer.

---

# **Step 5: Upload and Load Your Images**

Create a folder named **images/** in Studio Lab and upload images to it.

Example:

```
images/
 ├── dog1.jpg
 ├── flower.png
 └── car23.jpg
```

---

# **Step 6: Preprocess Images (Resize, Normalize, Batch)**

```python
# Define the image transformation pipeline
transform_pipeline = transforms.Compose([
    transforms.Resize((224, 224)),  # ResNet/VGG expect 224x224 inputs
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406], 
        std=[0.229, 0.224, 0.225]
    )
])
```

---

# **Step 7: Define Feature Extraction Function**

```python
# Extract features from the penultimate layer
feature_extractor = torch.nn.Sequential(*list(model.children())[:-1])

def extract_features(image_path):
    image = Image.open(image_path).convert("RGB")
    image = transform_pipeline(image)
    image = image.unsqueeze(0)  # Add batch dimension

    with torch.no_grad():
        features = feature_extractor(image)

    # Flatten 2048×1×1 → 2048
    features = features.numpy().flatten()
    return features
```

---

# **Step 8: Extract Features from All Images**

```python
image_folder = 'images'

# List all supported images
image_files = [f for f in os.listdir(image_folder)
               if f.lower().endswith(('.png', '.jpg', '.jpeg'))]

features_list = []
image_names = []

for img_name in image_files:
    img_path = os.path.join(image_folder, img_name)
    features = extract_features(img_path)
    features_list.append(features)
    image_names.append(img_name)

features_df = pd.DataFrame(features_list, index=image_names)
```

---

# **Step 9: Save Extracted Features**

```python
# Save as CSV
features_df.to_csv('image_features.csv')

# Save as binary NumPy file (optional)
np.save('image_features.npy', features_list)
```

---

# **Step 10: Verify Output**

```python
features_df.head()
```

---

# **Quick Recap**

✔ Load a ResNet50 pre-trained on ImageNet
✔ Preprocess images to model input size
✔ Extract 2048-dimensional feature embeddings
✔ Save embeddings to CSV or NumPy format

These embeddings can now be used for:

* Clustering (K-means, DBSCAN)
* Image similarity search (nearest neighbors)
* Training classifiers (Random Forest, Logistic Regression)
* Visualizations (PCA, t-SNE)

---

# **Recommended Public Image Datasets**

| Dataset             | Description                | Link                                                                                                   |
| ------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------ |
| CIFAR-10            | 60,000 small images        | [https://www.cs.toronto.edu/~kriz/cifar.html](https://www.cs.toronto.edu/~kriz/cifar.html)             |
| Fashion-MNIST       | 70k clothing images        | [https://github.com/zalandoresearch/fashion-mnist](https://github.com/zalandoresearch/fashion-mnist)   |
| Kaggle Cats vs Dogs | 25k pet images             | [https://www.kaggle.com/c/dogs-vs-cats](https://www.kaggle.com/c/dogs-vs-cats)                         |
| Oxford Flowers      | 17-category flower dataset | [https://www.robots.ox.ac.uk/~vgg/data/flowers/17/](https://www.robots.ox.ac.uk/~vgg/data/flowers/17/) |
| ImageNet Mini       | Small ImageNet subset      | [https://www.kaggle.com/ifigotin/imagenetmini-1000](https://www.kaggle.com/ifigotin/imagenetmini-1000) |

---

# **Sample CSV Output (Illustrative)**

| image_name     | f_1   | f_2   | … | f_2048 |
| -------------- | ----- | ----- | - | ------ |
| dog1.jpg       | 0.13  | -0.02 | … | 1.24   |
| flower_red.png | 0.98  | 0.65  | … | -0.84  |
| car23.jpg      | -0.33 | 0.11  | … | 0.42   |

---

# **Why Extracted CNN Features Are Useful**

These 2048-dimensional vectors represent **high-level visual features**, capturing:

* Edges, shapes, color gradients
* Object parts
* Scene-level patterns

You can use them to:

### **✔ Cluster similar images (unsupervised ML)**

Example: group cars, animals, clothes automatically.

### **✔ Perform image similarity search**

Example: “find images similar to this one.”

### **✔ Train lightweight ML models**

Use extracted features with Random Forest or Logistic Regression.

### **✔ Visualize image relationships**

Using PCA or t-SNE to see clusters spatially.

---

# **Common Pretrained Models in `torchvision.models`**

| Model                     | Output Size | Use Case                   |
| ------------------------- | ----------- | -------------------------- |
| ResNet (18–152)           | 512–2048    | Strong general-purpose CNN |
| VGG (11–19)               | 4096        | Feature-rich but heavy     |
| AlexNet                   | 4096        | Lightweight learning       |
| DenseNet                  | 1024–2208   | Efficient & accurate       |
| SqueezeNet                | 512         | Mobile/edge-friendly       |
| MobileNet v2/v3           | 1280        | Fast, small footprint      |
| EfficientNet B0–B7        | ~1280       | Modern SOTA architecture   |
| ConvNeXt                  | Varies      | ResNet successor           |
| Vision Transformers (ViT) | Varies      | Transformer-based SOTA     |

---

### **What is SOTA?**

**SOTA = State of the Art**

A model is considered SOTA if it achieves the **best-known performance** on a benchmark such as:

* **ImageNet accuracy** (vision)
* **MMLU, HellaSwag, GSM8K** (language models)
