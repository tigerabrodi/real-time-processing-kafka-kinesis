# Real Time Data Streaming with Kafka and Kinesis

I previously built a [Batch Processing system: S3 -> AWS Glue -> Snowflake](https://github.com/narutosstudent/aws-glue-etl-snowflake).

This time, I wanted to build a Real Time Data Streaming system using Kafka and Kinesis.

I've always heard of Kafka and it's wide spread usage. Plus, it was a nice fit because I wanted to build a real time data streaming system.

# Why I abandoned the project?

There are two main reasons why I abandoned the project:

- AWS costs rising and I hit my billing alert.
- Deploying changes to Kafka Cluster is very slow. Small changes take about 15 minutes to deploy. Other types of changes take 30 minutes, if not more.

Additionally, I felt like I learned enough from this project to be satisfied. Considering I used AWS Glue in my previous project already.

# Pre Study

I did some [pre study](https://github.com/narutosstudent/kafka-kinesis-notes) before embarking on this project.

# Visualization

![Screenshot 2024-01-22 at 18 23 07](https://github.com/narutosstudent/real-time-processing-kafka-kinesis/assets/49603590/85314dc3-0b68-482c-b149-7e2ef9003f48)

# Sequence of Events

1. **Event Generation**: Node.js backend generates event data.
2. **Publish to Kafka**: The backend publishes these events to a Kafka topic in Amazon MSK.
3. **MSK Handling**: The events reside in the Kafka topic, managed by MSK.
4. **Firehose Consumption**: Kinesis Firehose consumes the events from the Kafka topic.
5. **Aggregation and Buffering**: Firehose aggregates these events for 5 minutes.
6. **S3 Storage**: Aggregated events are stored in the S3 bucket with a timestamp-based naming convention.
7. **Logging and Monitoring**: All activities and system metrics are logged and monitored via CloudWatch.

# The Idea

You can imagine in a real world system where orders and other events in an ecommerce application is happening all the time and we want to capture these events in real time and process them for analytics.

From the company's perspective, we want to analyze the data to understand our customers better and make better business decisions.

# How could it be improved once done?

In a real-world application, optimizing data for analysis often involves transforming it into a columnar format like Parquet, which is efficient for queries and analytics. AWS Glue, a serverless ETL service, can automate the transformation of JSON or CSV data into Parquet.

I used it in my previous data engineering project, it was awesome!
