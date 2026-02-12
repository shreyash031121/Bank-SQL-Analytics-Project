# 🏦 Bank Transaction & Fraud Analytics (MySQL)

## 📌 Project Overview
This project performs advanced SQL-based analysis on bank transaction data to understand customer behavior, monitor account activity, and detect potential fraud patterns.

The analysis simulates real-world financial analytics scenarios such as transaction monitoring, risk scoring, and anomaly detection using structured SQL queries.

---

## 🗂 Dataset Description

The dataset contains structured transaction-level banking data including:

- Account_ID
- Transaction_ID
- Transaction_Date
- Transaction_Type (Credit/Debit)
- Transaction_Amount
- Account_Balance
- Customer_ID

Data is analyzed at transaction-level granularity to derive behavioral and risk insights.

---

## 🛠 Tools & Technologies

- MySQL
- SQL
- Window Functions (SUM, RANK, NTILE)
- GROUP BY & HAVING
- Self Joins
- Conditional Aggregation
- Date-based Filtering & Analysis

---

## 📊 Analysis Performed

- Calculated running account balance using window functions  
- Detected high-value transactions exceeding defined thresholds  
- Identified suspicious transaction patterns using time-based logic  
- Analyzed transaction frequency and behavior trends  
- Detected inactive accounts based on last transaction date  
- Ranked accounts based on transaction volume and risk indicators  
- Performed risk scoring using NTILE for segmentation  

---

## 🔍 Key Insights

- Identified accounts with unusual high-value transaction spikes  
- Detected rapid consecutive transactions indicating potential fraud  
- Highlighted dormant accounts requiring monitoring  
- Segmented accounts into risk categories using ranking logic  

---

## 🚀 Outcome

This project demonstrates strong SQL fundamentals, advanced query writing using window functions, and the ability to apply analytical thinking to financial fraud detection use cases — aligning with real-world Data Analyst and Banking Analytics roles.
