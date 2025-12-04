# Deciding When ML Is Appropriate**

## **Objective**

This exercise teaches you how to evaluate real-world business problems and determine whether machine learning is an appropriate solution. You will analyze multiple business scenarios using a structured worksheet and classify each scenario based on data availability, problem type, required outcomes, and complexity. By the end of this lab, you will be able to distinguish ML-appropriate use cases from those better solved through traditional rule-based or analytical methods.

---

## **Step 1: Access the Use Case Worksheet**

Create a worksheet named **`ML_Use_Case_Classification.xlsx`** (or a similar format).
The worksheet should include:

* A list of business scenarios
* A column to classify each scenario as ML-Applicable (Yes/No)
* A justification column to explain your decision

### **Sample Use Case Classification Worksheet**

| Use Case ID | Business Scenario                                                      | ML Applicable (Yes/No) | Justification                                                                      |
| ----------- | ---------------------------------------------------------------------- | ---------------------- | ---------------------------------------------------------------------------------- |
| **UC-001**  | Predict customer churn based on usage history and support interactions | Yes                    | Supervised learning can classify churn likelihood using labeled historical data.   |
| **UC-002**  | Display company policies to employees upon login                       | No                     | Static rules are sufficient; no prediction or learning is required.                |
| **UC-003**  | Recommend products based on customer browsing and purchase history     | Yes                    | ML techniques such as collaborative filtering enable personalized recommendations. |
| **UC-004**  | Calculate sales tax based on state and product type                    | No                     | Deterministic formulas or lookup tables solve this without ML.                     |
| **UC-005**  | Identify fraudulent transactions in real time                          | Yes                    | ML can detect anomalies and hidden patterns beyond simple rules.                   |
| **UC-006**  | Convert temperature from Fahrenheit to Celsius                         | No                     | Fully deterministic mathematical formula; no pattern learning needed.              |
| **UC-007**  | Categorize customer support tickets into topics based on text          | Yes                    | NLP-based text classification is well-suited for this task.                        |
| **UC-008**  | Schedule meetings based on participants’ calendars                     | No                     | Rule-based scheduling logic is more efficient and interpretable.                   |
| **UC-009**  | Forecast weekly product demand at retail stores                        | Yes                    | Time-series forecasting models can predict future demand based on trends.          |
| **UC-010**  | Route calls to the next available support agent                        | No                     | Queue management logic solves this without ML.                                     |

---

## **Step 2: Read Each Scenario Carefully**

Review each business scenario in the worksheet.
Identify the core objective:

* Is the business trying to **predict**, **recommend**, **automate**, or **detect patterns**?
* Or does the task rely on **fixed rules** that do not require learning from data?

---

## **Step 3: Analyze Key Decision Factors**

For each scenario, assess the following:

* **Prediction vs. rules** — Is the problem probabilistic or deterministic?
* **Historical data availability** — Is there enough data to learn patterns?
* **Pattern dependence** — Would pattern learning improve outcomes?
* **Output type** — Is the solution a predicted probability or a fixed value?

This structured analysis helps you determine whether ML offers measurable value.

---

## **Step 4: Classify the Scenario**

Label each use case in the worksheet as:

* **ML-Applicable** – If the problem benefits from pattern learning or prediction.
* **Not ML-Applicable** – If clear rules, formulas, or static logic fully solve the problem.

---

## **Step 5: Justify Your Classification**

In the justification column, include a brief explanation such as:

* Is data available?
* Would ML improve accuracy or automation?
* Are rules enough to solve the problem?
* Is the outcome deterministic or probabilistic?

These justifications reinforce your understanding of ML decision frameworks.

---

## **Optional Extension**

Analyze borderline or ambiguous cases to better understand situations where:

* ML adds value but may be unnecessary
* Rule-based approaches are possible but less scalable
* Data availability limits ML usefulness

This exercise deepens your ability to make informed, real-world ML applicability decisions.

