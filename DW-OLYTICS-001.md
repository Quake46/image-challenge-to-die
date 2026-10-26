# รายงานการวิเคราะห์ ออกแบบสถาปัตยกรรม และการพัฒนาระบบคลังข้อมูลและการวิเคราะห์เว็บ

**Data Warehouse & Web Analytics Architecture Design Document**

โครงการพัฒนาระบบคลังข้อมูลและแพลตฟอร์มวิเคราะห์ข้อมูลเว็บ (olytics-web) — Olytics ระบบคลังข้อมูลอีคอมเมิร์ซแบบอัตโนมัติบน AWS Cloud

`DW-OLYTICS-001` · เวอร์ชัน 1.0 · ฉบับเสนอพิจารณา · ใช้ภายในโครงการ (Internal)

---

**ตารางที่ 1** ข้อมูลควบคุมเอกสาร (Document Control)

| รายการ | รายละเอียด |
| --- | --- |
| **รหัสเอกสาร** | DW-OLYTICS-001 |
| **ชื่อโครงการ** | โครงการพัฒนาระบบคลังข้อมูลและแพลตฟอร์มวิเคราะห์ข้อมูลเว็บ (olytics-web) |
| **ชื่อระบบ** | Olytics — ระบบคลังข้อมูลอีคอมเมิร์ซแบบอัตโนมัติบน AWS Cloud พร้อมเว็บแอปพลิเคชันแสดงผล (Dashboard) |
| **แหล่งซอร์สโค้ดอ้างอิง** | https://github.com/NonKaweewat/olytics-web (สาขาหลัก ตรวจสอบ ณ วันที่ 26 ตุลาคม 2569) |
| **หน่วยงานเจ้าของโครงการ** | รายวิชา Cloud Technology Infrastructure คณะเทคโนโลยีสารสนเทศ สาขาวิทยาการข้อมูลและวิเคราะห์เชิงธุรกิจ สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง ภาคเรียนที่ 1 ปีการศึกษา 2569 |
| **ชุดข้อมูลธุรกิจ** | Olist Brazilian E-Commerce Public Dataset — คำสั่งซื้อประมาณ 100,000 รายการ ช่วงปี ค.ศ. 2016–2018 (ข้อมูลผ่านการปกปิดตัวตนจากผู้เผยแพร่) |
| **เวอร์ชันเอกสาร** | 1.0 |
| **วันที่จัดทำ** | 26 ตุลาคม 2569 |
| **ผู้จัดทำ** | ทีมโครงงาน Olytics (สถาปัตยกรรมข้อมูล วิศวกรรมข้อมูล และพัฒนาเว็บ) |
| **ผู้ทบทวน** | อาจารย์ผู้สอนรายวิชา และผู้รับผิดชอบข้อมูลของแต่ละส่วนงาน (Data / Web / Infrastructure) |
| **ผู้อนุมัติ** | อาจารย์ผู้สอนรายวิชา (ลงนามเมื่ออนุมัติตามตารางที่ 2) |
| **สถานะเอกสาร** | ฉบับเสนอพิจารณา |
| **ระดับชั้นความลับ** | ใช้ภายในโครงการ (Internal) |

เอกสารฉบับนี้กำหนดผลการวิเคราะห์ความต้องการทางธุรกิจ สถาปัตยกรรมข้อมูลบน Amazon Web Services โครงสร้างคลังข้อมูลแบบ Star Schema บน Amazon Redshift การผูกโยงข้อมูลจากระบบต้นทาง เงื่อนไขคุณภาพข้อมูล การควบคุมสิทธิ์และการคุ้มครองข้อมูลส่วนบุคคล การพัฒนาเว็บแอปพลิเคชัน olytics-web และเกณฑ์การตรวจรับของโครงการ **ขอบเขตระยะที่ 1** ครอบคลุมการวิเคราะห์ยอดขาย คำสั่งซื้อ การชำระเงิน ผู้ขาย การจัดส่ง และรีวิวลูกค้าจากชุดข้อมูล Olist ผ่าน KPI View จำนวน 15 รายการ ส่วน **ขอบเขตระยะที่ 2** ครอบคลุมการวิเคราะห์พฤติกรรมผู้ใช้บนเว็บ (Web Events / Sessions) การทำ Attribution Modeling และ Predictive Analytics ซึ่งเอกสารนี้กำหนดเป็นแบบออกแบบเพื่อการพัฒนาต่อ

**ตารางที่ 2** ผู้จัดทำ ผู้ทบทวน และผู้อนุมัติเอกสาร

| บทบาท | ผู้รับผิดชอบ | ขอบเขตที่รับผิดชอบ | ลงนาม / วันที่ |
| --- | --- | --- | --- |
| ผู้จัดทำ | ทีมโครงงาน Olytics<br>นายกวีวัฒน์ สานนท์กุลวัฒน์<br>นายธิติวัฒน์ สมพันธุ์เดชสกุล<br>นายภคพล โพธิวร<br>นายภัทรพล เพ็ชรรัตน์<br>นายภูวาริช กองจร | สถาปัตยกรรมข้อมูล ETL คลังข้อมูล เว็บแอปพลิเคชัน และเอกสาร | 26 ต.ค. 2569 |
| ผู้ทบทวนด้านข้อมูล | หัวหน้าทีม Data (ผู้ดูแล KPI View บน Redshift) | นิยาม KPI, Star Schema, กฎคุณภาพข้อมูล | ................ |
| ผู้ทบทวนด้านระบบ | ผู้ดูแลระบบ AWS / EC2 | สถาปัตยกรรม ความปลอดภัย การติดตั้ง | ................ |
| ผู้อนุมัติ | อาจารย์ผู้สอนรายวิชา Cloud Technology Infrastructure | อนุมัติขอบเขต การออกแบบ และเกณฑ์ตรวจรับ | ................ |

**ตารางที่ 3** ประวัติการแก้ไขเอกสาร

| เวอร์ชัน | วันที่ | รายละเอียดการแก้ไข | ผู้แก้ไข |
| --- | --- | --- | --- |
| 0.1 | 9 ส.ค. 2569 | รายงานความก้าวหน้า: ที่มา วัตถุประสงค์ ขอบเขต สถาปัตยกรรม AWS, Star Schema และ Use Case | ทีมโครงงาน |
| 0.5 | 24 ต.ค. 2569 | เพิ่มเว็บ Dashboard ตามบทบาท, Amazon Cognito, Query Lab และ Internal API บน EC2 | ทีมโครงงาน |
| 1.0 | 26 ต.ค. 2569 | จัดทำเป็นเอกสารออกแบบฉบับสมบูรณ์ตามมาตรฐาน DW-DSN: KPI, Data Contract, DQ, SCD, RBAC/PDPA, เกณฑ์ตรวจรับ และซอร์สโค้ดอ้างอิงในภาคผนวก | ทีมโครงงาน |

**ตารางที่ 4** สถานะของเนื้อหาในเอกสารเทียบกับซอร์สโค้ด

| สัญลักษณ์สถานะ | ความหมาย | ตัวอย่าง |
| --- | --- | --- |
| **[มีในระบบ]** | พัฒนาแล้วและมีหลักฐานในซอร์สโค้ดหรือเอกสารของ repository | olytics-web ทั้ง 9 หน้า, RBAC 9 บทบาท, Cognito, ec2-api, ER Diagram, KPI View 15 รายการ |
| **[ออกแบบในเอกสารนี้]** | แบบออกแบบและซอร์สโค้ดอ้างอิงที่จัดทำในเอกสารนี้ ผ่านการทดสอบบน PostgreSQL 16 แล้ว ต้องทดสอบซ้ำบน Amazon Redshift ก่อนใช้งานจริง | ตาราง ops ควบคุมรอบโหลด, Stored Procedure, กฎ DQ01–DQ11, Role ฐานข้อมูล, warehouse_loader.py |
| **[ระยะที่ 2]** | ข้อกำหนดเพื่อพัฒนาต่อ ยังไม่มีข้อมูลต้นทางหรือซอร์สโค้ด | Fact_Web_Events, Dim_Device, ตัวชี้วัด W01–W06, Attribution, Predictive, RLS ระดับรัฐ |

> **ข้อสังเกตด้านขอบเขตจากการตรวจสอบซอร์สโค้ด**
>
> repository olytics-web เป็นระบบคลังข้อมูลอีคอมเมิร์ซของชุดข้อมูล Olist บน AWS (S3, Lambda, Glue DataBrew, Glue ETL, Glue Data Catalog, Athena, Redshift, EC2, Cognito) ไม่มีข้อมูลเหตุการณ์การใช้งานเว็บ (clickstream), ข้อมูลสินค้าคงคลัง และไม่ได้ใช้ dbt หรือ Apache Airflow
>
> เอกสารจึงยึดโครงสร้างหัวข้อที่กำหนด โดยใช้ตาราง Olist จริงเป็นแกนหลัก (เช่น fact_order_item ทำหน้าที่ Fact_Sales_Transaction, dim_customer ทำหน้าที่ Dim_User, dim_seller ทำหน้าที่ Dim_Store/Channel) และกำหนดส่วนการวิเคราะห์เว็บเป็นแบบออกแบบระยะที่ 2 อย่างชัดเจน เพื่อไม่ให้ผู้อ่านเข้าใจว่าส่วนดังกล่าวพัฒนาแล้ว

## สารบัญ

- [1 บทนำ ความต้องการทางธุรกิจ และขอบเขตโครงการ](#1-บทนำ-ความต้องการทางธุรกิจ-และขอบเขตโครงการ)
  - [1.1 วัตถุประสงค์และบทนำโครงการ](#11-วัตถุประสงค์และบทนำโครงการ)
  - [1.2 ความต้องการทางธุรกิจ (Business Requirements)](#12-ความต้องการทางธุรกิจ-business-requirements)
  - [1.3 นิยามตัวชี้วัด (KPI Dictionary)](#13-นิยามตัวชี้วัด-kpi-dictionary)
  - [1.4 ขอบเขตโครงการและผลส่งมอบ](#14-ขอบเขตโครงการและผลส่งมอบ)
- [2 สถาปัตยกรรมระบบและระบบต้นทาง](#2-สถาปัตยกรรมระบบและระบบต้นทาง)
  - [2.1 โครงสร้างการไหลของข้อมูล (Data Flow Architecture)](#21-โครงสร้างการไหลของข้อมูล-data-flow-architecture)
  - [2.2 องค์ประกอบระบบและเทคโนโลยี (System Stack Specification)](#22-องค์ประกอบระบบและเทคโนโลยี-system-stack-specification)
  - [2.3 รายการระบบต้นทางและสัญญาข้อมูล (Data Contracts)](#23-รายการระบบต้นทางและสัญญาข้อมูล-data-contracts)
- [3 แบบจำลองข้อมูลและโครงสร้างคลังข้อมูล](#3-แบบจำลองข้อมูลและโครงสร้างคลังข้อมูล)
  - [3.1 Enterprise Data Warehouse Bus Matrix](#31-enterprise-data-warehouse-bus-matrix)
  - [3.2 ข้อกำหนดมิติร่วม (Conformed Dimensions)](#32-ข้อกำหนดมิติร่วม-conformed-dimensions)
  - [3.3 ทะเบียนตารางและแบบจำลองความสัมพันธ์ข้อมูล (ERD)](#33-ทะเบียนตารางและแบบจำลองความสัมพันธ์ข้อมูล-erd)
  - [3.4 โครงสร้างตารางข้อเท็จจริง (Fact Tables Details)](#34-โครงสร้างตารางข้อเท็จจริง-fact-tables-details)
  - [3.5 โครงสร้างตารางมิติ (Dimension Tables Details)](#35-โครงสร้างตารางมิติ-dimension-tables-details)
  - [3.6 ข้อกำหนดการจัดการประวัติข้อมูล (SCD Policy)](#36-ข้อกำหนดการจัดการประวัติข้อมูล-scd-policy)
- [4 กระบวนการรับ แปลง และโหลดข้อมูล](#4-กระบวนการรับ-แปลง-และโหลดข้อมูล)
  - [4.1 Source to Target Mapping](#41-source-to-target-mapping)
  - [4.2 เงื่อนไขคุณภาพข้อมูล (Data Quality Rules)](#42-เงื่อนไขคุณภาพข้อมูล-data-quality-rules)
  - [4.3 กลยุทธ์การโหลดข้อมูลและการควบคุม Transaction (Load Strategy & Recovery)](#43-กลยุทธ์การโหลดข้อมูลและการควบคุม-transaction-load-strategy--recovery)
- [5 การกำกับดูแล ความปลอดภัย และสิทธิ์การใช้งาน](#5-การกำกับดูแล-ความปลอดภัย-และสิทธิ์การใช้งาน)
  - [5.1 การกำหนดสิทธิ์ตามบทบาท (Role-Based Access Control)](#51-การกำหนดสิทธิ์ตามบทบาท-role-based-access-control)
  - [5.2 นโยบายความปลอดภัยและการคุ้มครองข้อมูลส่วนบุคคล (PDPA & Data Protection Policy)](#52-นโยบายความปลอดภัยและการคุ้มครองข้อมูลส่วนบุคคล-pdpa--data-protection-policy)
- [6 การนำไปใช้งานและส่วนต่อประสานผู้ใช้](#6-การนำไปใช้งานและส่วนต่อประสานผู้ใช้)
  - [6.1 โครงสร้างส่วนหน้าและระบบแสดงผล olytics-web (Frontend Implementation)](#61-โครงสร้างส่วนหน้าและระบบแสดงผล-olytics-web-frontend-implementation)
  - [6.2 แผงควบคุมและรายงานการวิเคราะห์ (Analytics Dashboard Screenshots)](#62-แผงควบคุมและรายงานการวิเคราะห์-analytics-dashboard-screenshots)
- [7 การทดสอบ การรับมอบ และแผนการส่งมอบ](#7-การทดสอบ-การรับมอบ-และแผนการส่งมอบ)
  - [7.1 เกณฑ์ตรวจรับระบบ (Acceptance Test Specifications)](#71-เกณฑ์ตรวจรับระบบ-acceptance-test-specifications)
  - [7.2 สรุปรายการผลส่งมอบ (Deliverables Matrix)](#72-สรุปรายการผลส่งมอบ-deliverables-matrix)
  - [7.3 แผนการส่งมอบและนำขึ้นใช้งาน](#73-แผนการส่งมอบและนำขึ้นใช้งาน)
- [ภาคผนวก ซอร์สโค้ดอ้างอิง](#ภาคผนวก-ซอร์สโค้ดอ้างอิง)
  - [ภาคผนวก ก ซอร์สโค้ด DDL สร้างโครงสร้างฐานข้อมูล (001_schema.sql)](#ภาคผนวก-ก-ซอร์สโค้ด-ddl-สร้างโครงสร้างฐานข้อมูล-001_schemasql)
  - [ภาคผนวก ข ซอร์สโค้ด Stored Procedures และ Data Publishing (002_publish.sql)](#ภาคผนวก-ข-ซอร์สโค้ด-stored-procedures-และ-data-publishing-002_publishsql)
  - [ภาคผนวก ค ซอร์สโค้ดโปรแกรมโหลดและแปลงข้อมูล Python (warehouse_loader.py)](#ภาคผนวก-ค-ซอร์สโค้ดโปรแกรมโหลดและแปลงข้อมูล-python-warehouse_loaderpy)
  - [ภาคผนวก ง การกำหนดสิทธิ์และ Security Views (003_security.sql)](#ภาคผนวก-ง-การกำหนดสิทธิ์และ-security-views-003_securitysql)

## 1 บทนำ ความต้องการทางธุรกิจ และขอบเขตโครงการ

### 1.1 วัตถุประสงค์และบทนำโครงการ

ธุรกิจพาณิชย์อิเล็กทรอนิกส์สร้างข้อมูลจำนวนมากในแต่ละวัน ทั้งคำสั่งซื้อ รายการสินค้า การชำระเงิน การจัดส่ง และรีวิวของผู้ซื้อ ข้อมูลเหล่านี้จัดเก็บอยู่ในระบบธุรกรรม (OLTP) ที่ออกแบบเพื่อบันทึกรายการอย่างรวดเร็ว จึงไม่เหมาะต่อการวิเคราะห์เชิงลึกที่ต้องเชื่อมโยงหลายตารางและย้อนดูแนวโน้มระยะยาว อีกทั้งการสืบค้นหนัก ๆ บนระบบธุรกรรมยังกระทบประสิทธิภาพการให้บริการลูกค้า

โครงการ Olytics จึงพัฒนาคลังข้อมูลบน Amazon Web Services ภายใต้สภาพแวดล้อม AWS Academy Learner Lab โดยนำชุดข้อมูลจริงของ Olist ประเทศบราซิล (คำสั่งซื้อประมาณ 100,000 รายการ ปี ค.ศ. 2016–2018) แบ่งเป็นชุดย่อยตามช่วงเวลาเพื่อจำลองการทยอยเข้ามาของข้อมูล เมื่อไฟล์ชุดใหม่เข้าสู่ S3 Raw Zone ระบบจะสั่งงาน ETL โดยอัตโนมัติผ่าน AWS Lambda ทำความสะอาดด้วย AWS Glue DataBrew แปลงเป็น Star Schema ด้วย AWS Glue ETL Job จัดเก็บใน S3 Curated Zone และโหลดเข้า Amazon Redshift จากนั้นทีมข้อมูลสร้าง KPI View 15 รายการ (`dw.v_br01` … `v_br14`) เป็นชั้นความหมายกลาง (Semantic Layer)

เว็บแอปพลิเคชัน **olytics-web** (Next.js 15 และ React 19 บน Amazon EC2) อ่านเฉพาะ KPI View ผ่านพอร์ต 5439 แสดงผลเป็นแผงควบคุมตามบทบาทของผู้ใช้ 9 บทบาท โดยยืนยันตัวตนผ่าน Amazon Cognito และควบคุมสิทธิ์ทุกหน้าและทุก API ที่ middleware ตัวเลขบนเว็บจึงตรงกับที่ทีมข้อมูลคำนวณ และนอกจากนี้ยังมี Query Lab สำหรับนักวิเคราะห์เพื่อสืบค้นด้วย SQL แบบอ่านอย่างเดียว และ Internal API (`ec2-api`) ที่เปิดข้อมูล KPI ทั้ง 15 รายการในรูป JSON สำหรับการเชื่อมต่อภายใน

ในระยะถัดไป แพลตฟอร์มจะขยายไปสู่การรวบรวมข้อมูลพฤติกรรมผู้ใช้บนเว็บ (Web Events / Traffic) เพื่อเชื่อมโยงการเข้าชมกับยอดขาย เอกสารนี้กำหนดแบบจำลองข้อมูล สัญญาข้อมูล ตัวชี้วัด และกฎคุณภาพสำหรับส่วนดังกล่าวไว้ล่วงหน้า (ระบุสถานะ [ระยะที่ 2]) เพื่อให้ต่อยอดได้โดยไม่ต้องปรับโครงสร้างคลังข้อมูลเดิม

วัตถุประสงค์ของโครงการมีดังนี้

1. ออกแบบสถาปัตยกรรมคลังข้อมูลบนคลาวด์ด้วยบริการของ AWS ภายใต้ข้อจำกัดของ Learner Lab
2. พัฒนากระบวนการ ETL อัตโนมัติที่เริ่มทำงานเองเมื่อมีข้อมูลชุดใหม่ และแปลงข้อมูลเป็น Star Schema
3. จัดทำนิยามตัวชี้วัดกลาง (KPI Dictionary) และ KPI View ที่ทุกช่องทางแสดงผลใช้ร่วมกัน
4. เปรียบเทียบการสืบค้นแบบ Serverless ด้วย Amazon Athena กับคลังข้อมูลเฉพาะทาง Amazon Redshift
5. นำเสนอผลวิเคราะห์ผ่านเว็บแอปพลิเคชันที่จำกัดการมองเห็นตามบทบาทและคุ้มครองข้อมูลส่วนบุคคล
6. วางรากฐานข้อมูลสำหรับการวิเคราะห์พฤติกรรมผู้ใช้บนเว็บและการวิเคราะห์เชิงพยากรณ์ในระยะที่ 2

**ตารางที่ 5** ผู้ใช้ข้อมูลและความรับผิดชอบ

| บทบาท (Role) | การใช้ข้อมูล | ความรับผิดชอบ |
| --- | --- | --- |
| ผู้บริหาร<br>`executive` | ภาพรวมยอดขาย จำนวนคำสั่งซื้อ ลูกค้า อัตราซื้อซ้ำ การเติบโตรายเดือน หมวดสินค้าและรัฐที่ทำยอดสูงสุด (หน้า Overview) | ยืนยันนิยามยอดขาย (M01) สกุลเงิน และการตัดคำสั่งซื้อที่ยกเลิกออกจากยอดขาย |
| การเงินและการชำระเงิน<br>`finance` | สัดส่วนมูลค่าตามวิธีชำระเงิน จำนวนรายการชำระ และการกระทบยอดกับยอดขาย (หน้า Payments) | ยืนยันนิยามมูลค่าการชำระเงิน (M06) และเกณฑ์ผลต่างยอดชำระกับยอดสินค้า (DQ06) |
| บริหารหมวดสินค้า<br>`category` | ยอดขาย จำนวนชิ้น ราคาเฉลี่ยต่อชิ้น และแนวโน้มรายเดือนของแต่ละหมวด (หน้า Categories) | ยืนยันการจัดหมวดและคำแปลหมวดสินค้า (category_english) |
| ฝ่ายดูแลผู้ขาย<br>`seller` | ผลงานผู้ขาย อัตราส่งมอบให้ขนส่งทันเวลา และผู้ขายที่ไม่มียอดขาย (หน้า Sellers) | ยืนยันข้อมูลหลักผู้ขายและนิยามการส่งมอบทันเวลา (M07) |
| โลจิสติกส์และการจัดส่ง<br>`logistics` | อัตราส่งช้าและระยะเวลาจัดส่งตามรัฐและภาคของลูกค้า (หน้า Delivery) | ยืนยันนิยามการส่งช้า (M09) และวันจัดส่ง (M10) |
| ลูกค้าและประสบการณ์ลูกค้า<br>`cx` | คะแนนรีวิว การกระจายคะแนน อัตราซื้อซ้ำ และอัตราคำสั่งซื้อล้มเหลว (หน้า Customers & Reviews) | ยืนยันกฎรีวิวล่าสุดต่อคำสั่งซื้อ (M08) และนิยามลูกค้าซื้อซ้ำ (M11) |
| การตลาด<br>`marketing` | ภูมิศาสตร์ลูกค้าตามรัฐ ภาค และเมือง ยอดขายรายเดือนตามหมวด (หน้า Marketing) และในระยะที่ 2 ข้อมูลการเข้าชมเว็บและ Conversion | ใช้ข้อมูลตามวัตถุประสงค์ที่ได้รับอนุญาต และยืนยันนิยามตัวชี้วัดเว็บ W01–W06 |
| นักวิเคราะห์ / BI<br>`analyst` | ทุกแผงควบคุม และ Query Lab สำหรับสืบค้น SQL แบบอ่านอย่างเดียว | ใช้สูตรกลางจากทะเบียน KPI ไม่เฉลี่ยค่าเฉลี่ย และตรวจผลรวมกับ View ต้นทาง |
| ผู้ดูแลระบบ<br>`admin` | ทุกหน้า รวมถึง Settings (สถานะการเชื่อมต่อคลังข้อมูล ความหน่วง และสิทธิ์ของแต่ละบทบาท) | บริหารบัญชีใน Cognito Group, ค่าคอนฟิกบน EC2, Security Group และการสำรอง/กู้คืน |
| วิศวกรข้อมูล<br>(Data Engineer) | บันทึกรอบโหลด `ops.load_batch`, รายการที่ไม่ผ่านกฎ `ops.reject_record` และ Log ของ Glue/Lambda | ดูแล Data Contract, Pipeline, KPI View, การกระทบยอด และการโหลดซ้ำ (Replay) |

### 1.2 ความต้องการทางธุรกิจ (Business Requirements)

ความต้องการทางธุรกิจกำหนดรหัส BR ให้ตรงกับชื่อ KPI View ในคลังข้อมูลและหน้าเว็บที่ใช้งาน (`lib/roles.ts`) ทำให้ตรวจย้อนจากคำถามธุรกิจไปยังตัวชี้วัด View และหน้าจอได้โดยตรง ข้อมูลระยะที่ 1 มาจากชุดข้อมูล Olist ซึ่งทยอยเข้าเป็นรอบตามช่วงเวลา (Event-driven Batch) ส่วนเว็บสืบค้น View ทุกครั้งที่เปิดหน้า จึงแสดงข้อมูลของรอบล่าสุดที่เผยแพร่สำเร็จ

**ตารางที่ 6** ความต้องการทางธุรกิจและตัวชี้วัด

| รหัสและผู้ใช้ | คำถามทางธุรกิจ | ระดับวิเคราะห์และข้อมูล (KPI View) | KPI / ระยะ |
| --- | --- | --- | --- |
| BR01<br>ผู้บริหาร | ยอดขายและจำนวนคำสั่งซื้อรายเดือนเป็นเท่าไร เติบโตจากเดือนก่อนกี่เปอร์เซ็นต์ | ปี เดือน รัฐลูกค้า<br>`v_br01_monthly_sales` | M01 M02 M17<br>ระยะที่ 1 |
| BR02<br>ผู้บริหาร | รัฐและหมวดสินค้าใดทำยอดขายสูงสุด 5 อันดับแรก | รัฐลูกค้า / หมวดสินค้า<br>`v_br02_top_states`, `v_br02_top_categories` | M01 M02 M03<br>ระยะที่ 1 |
| BR03<br>การเงิน | มูลค่าการชำระเงินแบ่งตามวิธีชำระเป็นสัดส่วนเท่าไร | ปี เดือน รัฐ วิธีชำระ<br>`v_br03_payment_distribution` | M06<br>ระยะที่ 1 |
| BR04<br>หมวดสินค้า | แต่ละหมวดมียอดขาย จำนวนชิ้น และราคาเฉลี่ยต่อชิ้นเท่าไร | หมวดสินค้า<br>`v_br04_category_performance` | M01 M03 M05<br>ระยะที่ 1 |
| BR05<br>ผู้ขาย | ผู้ขายแต่ละรายมียอดขาย คำสั่งซื้อ และคะแนนรีวิวเฉลี่ยเท่าไร | ปี เดือน ผู้ขาย รัฐผู้ขาย<br>`v_br05_seller_performance` | M01 M02 M08<br>ระยะที่ 1 |
| BR06<br>ผู้ขาย | ผู้ขายส่งมอบสินค้าให้ขนส่งทันกำหนดกี่เปอร์เซ็นต์ | ปี เดือน ผู้ขาย รัฐผู้ขาย<br>`v_br06_seller_on_time` | M07<br>ระยะที่ 1 |
| BR07<br>ผู้ขาย | มีผู้ขายที่ไม่มียอดขายกี่รายและกี่เปอร์เซ็นต์ในแต่ละรัฐ | รัฐผู้ขาย ปี (และแถวรวมทุกปี)<br>`v_br07_sellers_without_revenue` | M13<br>ระยะที่ 1 |
| BR08<br>โลจิสติกส์ | คำสั่งซื้อที่ส่งถึงลูกค้าช้ากว่ากำหนดมีสัดส่วนเท่าไร | ปี เดือน รัฐลูกค้า<br>`v_br08_late_delivery` | M09<br>ระยะที่ 1 |
| BR09<br>โลจิสติกส์ | ระยะเวลาจัดส่งเฉลี่ย ต่ำสุด และสูงสุดกี่วัน | ปี เดือน รัฐลูกค้า<br>`v_br09_delivery_days` | M10<br>ระยะที่ 1 |
| BR10<br>CX | ลูกค้าให้คะแนนรีวิวเฉลี่ยเท่าไร และกระจายตัวอย่างไร | ปี เดือน รัฐ คะแนน<br>`v_br10_review_satisfaction` | M08<br>ระยะที่ 1 |
| BR11<br>CX | ลูกค้ากลับมาซื้อซ้ำกี่เปอร์เซ็นต์ | ลูกค้าบุคคล (customer_unique_id) ปี รัฐ<br>`v_br11_repeat_customers` | M11 M14<br>ระยะที่ 1 |
| BR12<br>CX | คำสั่งซื้อถูกยกเลิกหรือไม่มีสินค้ากี่เปอร์เซ็นต์ | ปี เดือน รัฐลูกค้า<br>`v_br12_order_failure_rate` | M12<br>ระยะที่ 1 |
| BR13<br>การตลาด | ลูกค้าอยู่ที่รัฐและเมืองใด แต่ละพื้นที่มียอดขายและมูลค่าต่อคำสั่งซื้อเท่าไร | ปี เดือน รัฐ เมือง<br>`v_br13_customer_geography` | M14 M04<br>ระยะที่ 1 |
| BR14<br>การตลาด / หมวด | ยอดขายรายเดือนของแต่ละหมวดสินค้าเป็นอย่างไร | ปี เดือน หมวด รัฐ<br>`v_br14_monthly_category_sales` | M15<br>ระยะที่ 1 |
| BR15<br>การตลาด | เว็บมีผู้เข้าชม หน้าที่ถูกเปิด ระยะเวลาใช้งาน และอัตราตีกลับเท่าไร | วัน ชั่วโมง หน้า อุปกรณ์ ช่องทาง<br>`Fact_Web_Events` (ออกแบบ) | W01–W04<br>ระยะที่ 2 |
| BR16<br>การตลาด / ผู้บริหาร | Session ที่เกิดคำสั่งซื้อมีสัดส่วนเท่าไร และรายได้ต่อ Session เป็นเท่าไร | Session เชื่อมคำสั่งซื้อ<br>`Fact_Web_Events` + `fact_order` | W05 W06<br>ระยะที่ 2 |
| BR17<br>ผู้บริหาร | ช่องทางใดมีส่วนต่อยอดขาย และคาดการณ์ยอดขาย/การส่งช้าในอนาคต | Attribution Model, Forecast Model<br>(ต้องมีข้อมูล BR15–BR16 ก่อน) | —<br>ระยะที่ 2 |

### 1.3 นิยามตัวชี้วัด (KPI Dictionary)

ตัวเงินทั้งหมดเป็นเงินเรียลบราซิล (BRL, R$) ตามข้อมูลต้นทาง ไม่แปลงสกุลเงินและไม่รวมภาษี **ยอดขาย** หมายถึงผลรวมราคาสินค้า (`price`) ระดับรายการ ไม่รวมค่าขนส่ง และตัดรายการของคำสั่งซื้อสถานะ `canceled` และ `unavailable` ออก ตัวหารที่เป็นศูนย์ใช้ `NULLIF(ตัวหาร, 0)` ให้ผลเป็น NULL และเว็บแสดงเป็น “—” แทนศูนย์

เมื่อเว็บรวมหลายแถวของ View (เช่น หลายเดือนหรือหลายรัฐ) จะคำนวณอัตราและค่าเฉลี่ยใหม่จากผลรวมตัวตั้งและตัวหาร ไม่เฉลี่ยค่าเฉลี่ย (`lib/metrics/*.ts`) ส่วนตัวชี้วัดที่นับไม่ซ้ำ (ลูกค้า ผู้ขาย) จะไม่รวมข้ามกลุ่ม แต่อ่านจากแถวรวมที่ View เตรียมไว้ (คอลัมน์มิติเป็น NULL) ตามกลไก `queryTotals()` ใน `lib/scope.ts`

**ตารางที่ 7** ทะเบียนตัวชี้วัดระยะที่ 1 (M01–M17)

| รหัสและชื่อ | สูตรและหน่วย | ข้อกำหนดการคำนวณ |
| --- | --- | --- |
| M01 ยอดขายสินค้า<br>(Gross Merchandise Sales) | `SUM(price)` บาทบราซิล (R$) | จาก `vw_sale_items` (ตัด canceled / unavailable) ไม่รวม freight_value; รวมข้ามเดือนได้ |
| M02 จำนวนคำสั่งซื้อ<br>(Total Orders) | `COUNT(DISTINCT order_id)` คำสั่งซื้อ | คำสั่งซื้อหนึ่งรายการอยู่ในเดือนเดียว จึงรวมรายเดือนได้ แต่ห้ามรวมข้ามหมวดสินค้า (คำสั่งซื้อหลายหมวดจะนับซ้ำ) ให้ใช้ v_br01 |
| M03 จำนวนชิ้นที่ขาย<br>(Items Sold) | `COUNT(*)` ของรายการสินค้า ชิ้น | หนึ่งแถวของ fact_order_item = 1 ชิ้น (item_count = 1) |
| M04 มูลค่าเฉลี่ยต่อคำสั่งซื้อ<br>(Average Order Value) | `M01 / NULLIF(M02, 0)` R$ ต่อคำสั่งซื้อ | คำนวณจากผลรวมในช่วงเดียวกัน ไม่เฉลี่ยค่า AOV ของเมืองหรือรัฐ |
| M05 ราคาเฉลี่ยต่อชิ้น<br>(Average Item Price) | `M01 / NULLIF(M03, 0)` R$ ต่อชิ้น | ใช้ใน BR04 และการ์ดภาพรวม |
| M06 สัดส่วนตามวิธีชำระ<br>(Payment Share) | `100 * SUM(payment_value)` ของวิธีนั้น `/ NULLIF(SUM(payment_value), 0)` % | นับทุกสถานะคำสั่งซื้อ; หนึ่งคำสั่งซื้ออาจมีหลายรายการชำระ (payment_sequential) |
| M07 อัตราส่งมอบให้ขนส่งทันเวลา<br>(Seller On-time Handover) | `100 * on_time_orders / NULLIF(on_time_orders + late_orders, 0)` % | Grain คำสั่งซื้อ×ผู้ขาย: ทันเวลาเมื่อทุกรายการที่มีวันส่งมอบขนส่ง &lt;= shipping_limit_date; คำสั่งซื้อที่ไม่มีวันส่งมอบนับเป็น unknown และไม่อยู่ในตัวหาร |
| M08 คะแนนรีวิวเฉลี่ย<br>(Average Review Score) | `SUM(review_score * review_count) / NULLIF(SUM(review_count), 0)` คะแนน (1–5) | ใช้รีวิวล่าสุดหนึ่งรายการต่อคำสั่งซื้อ (`vw_latest_review`) และนับเดือนตามวันที่รีวิว |
| M09 อัตราส่งช้า<br>(Late Delivery Rate) | `100 * SUM(late_orders) / NULLIF(SUM(total_delivered_orders), 0)` % | เฉพาะคำสั่งซื้อที่ส่งถึงแล้วและมีวันที่ส่งถึง; ช้าเมื่อวันที่ส่งถึงลูกค้า > วันที่ประมาณการ (late_flag = 1) |
| M10 ระยะเวลาจัดส่งเฉลี่ย<br>(Average Delivery Days) | `SUM(sum_delivery_days) / NULLIF(SUM(total_delivered_orders), 0)` วัน | delivery_days = (วันเวลาส่งถึงลูกค้า − วันเวลาสั่งซื้อ) / 86,400 วินาที ทศนิยม 2 ตำแหน่ง |
| M11 อัตราลูกค้าซื้อซ้ำ<br>(Repeat Customer Rate) | `100 * repeat_customers / NULLIF(total_customers, 0)` % | ลูกค้านับตาม customer_unique_id; ซื้อซ้ำเมื่อมีคำสั่งซื้อที่นับยอด >= 2 รายการภายในกลุ่มที่เลือก |
| M12 อัตราคำสั่งซื้อล้มเหลว<br>(Order Failure Rate) | `100 * (canceled + unavailable) / NULLIF(total_orders, 0)` % | แยกย่อยเป็นอัตรายกเลิก (cancellation_rate_pct) และอัตราไม่มีสินค้า (unavailable_rate_pct) |
| M13 อัตราผู้ขายไม่มียอดขาย<br>(Sellers without Revenue) | `100 * sellers_without_revenue / NULLIF(total_sellers, 0)` % | ผู้ขายทั้งหมดใน dim_seller (ไม่รวมสมาชิก Unknown) เทียบผู้ขายที่มีรายการขายนับยอดในปีหรือทุกปี |
| M14 จำนวนลูกค้าไม่ซ้ำ<br>(Unique Customers) | `COUNT(DISTINCT customer_unique_id)` ราย | ห้ามรวมข้ามรัฐหรือเดือน ให้ใช้แถวรวมของ v_br11 หรือคำนวณใหม่จาก Fact |
| M15 สัดส่วนยอดขายหมวดสินค้า<br>(Category Sales Share) | `100 * M01` ของหมวด `/ NULLIF(M01` ทั้งหมด`, 0)` % | ใช้ v_br14 ในช่วงเวลาเดียวกัน |
| M16 ค่าขนส่งเฉลี่ยต่อคำสั่งซื้อ<br>(Average Freight per Order) | `SUM(total_freight) / NULLIF(COUNT(order_id), 0)` R$ | ข้อมูลพร้อมใน fact_order แต่ยังไม่มี KPI View (การ์ด Avg. Freight ใน UI Prototype) — เพิ่มใน v_br01 รุ่นถัดไป |
| M17 การเติบโตยอดขายจากเดือนก่อน<br>(MoM Sales Growth) | `100 * (M01 เดือนนี้ − M01 เดือนก่อน) / NULLIF(M01 เดือนก่อน, 0)` % | เมื่อ View แยกรายรัฐ เว็บคำนวณใหม่จากผลรวมของเดือนปฏิทินก่อนหน้า (`lib/metrics/overview.ts`) |

**ตารางที่ 8** ทะเบียนตัวชี้วัดการวิเคราะห์เว็บ ระยะที่ 2 (W01–W06)

| รหัสและชื่อ | สูตรและหน่วย | ข้อกำหนดการคำนวณ |
| --- | --- | --- |
| W01 จำนวนการเปิดหน้า<br>(Page Views) | `COUNT(event_key)` WHERE `event_type = 'page_view'` ครั้ง | ตัดเหตุการณ์จาก Bot ที่ระบุใน Dim_Device (is_bot = TRUE) และเหตุการณ์ซ้ำตาม event_id |
| W02 ผู้เข้าชมไม่ซ้ำ<br>(Unique Visitors) | `COUNT(DISTINCT visitor_pseudo_id)` ราย | visitor_pseudo_id = HMAC-SHA256 ของ anonymous_id; ห้ามรวมข้ามวัน ให้คำนวณใหม่ตามช่วงที่เลือก |
| W03 ระยะเวลาเฉลี่ยต่อ Session<br>(Avg. Session Duration) | `SUM(session_duration_sec) / NULLIF(COUNT(DISTINCT session_id), 0)` วินาที | Session สิ้นสุดเมื่อไม่มีเหตุการณ์ 30 นาที (DQ12) หรือข้ามเที่ยงคืนตามเวลา Asia/Bangkok |
| W04 อัตราตีกลับ<br>(Bounce Rate) | `100 * bounced_sessions / NULLIF(total_sessions, 0)` % | Bounce = Session ที่มี page_view เดียวและไม่มีเหตุการณ์โต้ตอบ (click, add_to_cart, purchase) |
| W05 อัตราการเปลี่ยนเป็นคำสั่งซื้อ<br>(Conversion Rate) | `100 * converted_sessions / NULLIF(total_sessions, 0)` % | Converted = Session ที่มีเหตุการณ์ purchase ซึ่งจับคู่ order_id ใน fact_order ได้ |
| W06 รายได้ต่อ Session<br>(Revenue per Session) | `SUM(price ของคำสั่งซื้อที่ attribution) / NULLIF(total_sessions, 0)` R$ | ใช้นิยามยอดขาย M01 และวิธี Attribution ที่ฝ่ายการตลาดอนุมัติ |

### 1.4 ขอบเขตโครงการและผลส่งมอบ

**ตารางที่ 9** ขอบเขตโครงการและผลส่งมอบ

| ระยะและขอบเขต | ผลส่งมอบ | เกณฑ์รับมอบ / สถานะ |
| --- | --- | --- |
| ระยะที่ 1<br>นำเข้าและประมวลผลอัตโนมัติ | S3 Raw/Curated Zone, Lambda S3 Trigger, Glue DataBrew, Glue ETL Job, Glue Data Catalog/Crawler, CloudWatch และ SNS | ไฟล์ชุดใหม่เริ่ม Pipeline ได้เองโดยไม่ต้องสั่งงานด้วยมือ [มีในระบบ] |
| ระยะที่ 1<br>Core Sales Fact และคลังข้อมูล | Star Schema 4 Fact (order, order_item, payment, review) และ 7 Dimension บน Redshift ตาม ER Diagram | จำนวนแถวและยอดรวมตรง Control Totals (AT01, AT04) [มีในระบบ] + ตารางควบคุม ops [ออกแบบในเอกสารนี้] |
| ระยะที่ 1<br>KPI View และ Semantic Layer | KPI View 15 รายการ `dw.v_br01` … `v_br14` ตามทะเบียน M01–M17 | สูตรตรงทะเบียน KPI และยอด View ตรง Fact (AT07) [มีในระบบ] |
| ระยะที่ 1<br>Executive Dashboard และแผงควบคุมตามบทบาท | olytics-web: Overview, Payments, Categories, Sellers, Delivery, Customers & Reviews, Marketing, Query Lab, Settings | แต่ละบทบาทเห็นเฉพาะหน้าที่มีสิทธิ์ (AT08) [มีในระบบ] |
| ระยะที่ 1<br>ความปลอดภัยและการเข้าถึง | Amazon Cognito (Group = Role), Session Cookie ลงลายมือชื่อ HMAC, Security Group, Internal API แบบ loopback | ผ่าน AT08 และการทดสอบ ec2-api 46 รายการ [มีในระบบ] |
| ระยะที่ 1<br>Inventory Snapshot | ไม่อยู่ในชุดข้อมูล Olist (ไม่มีข้อมูลยอดคงเหลือสินค้า) | ย้ายไประยะที่ 2 เมื่อมีระบบคลังสินค้าเป็นต้นทาง |
| ระยะที่ 2<br>Core Web Analytics | Web Event Collector, Fact_Web_Events, Dim_Device, Dim_Page, ตัวชี้วัด W01–W06 และหน้าแผงควบคุม Web Traffic | ผ่าน DQ12 และการกระทบยอดเหตุการณ์ [ระยะที่ 2] |
| ระยะที่ 2<br>Attribution Modeling | แบบจำลอง Last-touch / Position-based เชื่อม Session กับคำสั่งซื้อ | ฝ่ายการตลาดอนุมัติวิธี Attribution [ระยะที่ 2] |
| ระยะที่ 2<br>Predictive Analytics | พยากรณ์ยอดขายรายเดือนและความเสี่ยงส่งช้า (เช่น Amazon SageMaker หรือ Redshift ML) | ประเมินความแม่นยำบนข้อมูลทดสอบที่แยกช่วงเวลา [ระยะที่ 2] |
| นอกขอบเขต | การประมวลผลแบบ Real-time Streaming, Amazon QuickSight (ใช้ไม่ได้ใน Learner Lab), งบการเงินตามกฎหมาย | ไม่มีการพัฒนาในโครงการนี้ |

## 2 สถาปัตยกรรมระบบและระบบต้นทาง

ระบบทำงานบน AWS Region `us-east-1` ภายใต้ AWS Academy Learner Lab โดยแยกพื้นที่จัดเก็บเป็น Data Lake บน Amazon S3 (Raw Zone และ Curated Zone) และคลังข้อมูล Amazon Redshift ใน Private Subnet ของ VPC เว็บแอปพลิเคชันอยู่บน Amazon EC2 ใน Public Subnet และเชื่อมต่อ Redshift ได้เฉพาะพอร์ต 5439 จาก Security Group ของ EC2 เท่านั้น การสั่งงานทั้งหมดใช้สิทธิ์ผ่าน `LabRole` เนื่องจาก Learner Lab ไม่อนุญาตให้สร้าง IAM Role ใหม่

### 2.1 โครงสร้างการไหลของข้อมูล (Data Flow Architecture)

**ตารางที่ 10** สถาปัตยกรรมข้อมูลแยกตามชั้น

| ชั้นข้อมูล | องค์ประกอบและการประมวลผล | ผลลัพธ์และเงื่อนไขส่งต่อ |
| --- | --- | --- |
| ระบบต้นทาง<br>(Source) | ฐานข้อมูล Olist ถูกส่งออกเป็นไฟล์ CSV แบ่งชุดตามช่วงเวลา พร้อม `manifest.json` (ชื่อชุด ช่วงวันที่ SHA-256 และจำนวนแถวของทุกไฟล์); ระยะที่ 2 เพิ่ม Web Event Collector จากหน้าเว็บผ่าน API Gateway | ผู้ส่งอัปโหลด manifest.json เป็นไฟล์สุดท้ายของชุด เพื่อบอกว่าไฟล์ครบ |
| ชั้น raw<br>(S3 Raw Zone) | `s3://<bucket>/raw/batch=<ชื่อชุด>/` เก็บไฟล์ต้นฉบับไม่แก้ไข เข้ารหัส SSE-S3; S3 Event Notification (suffix manifest.json) เรียก AWS Lambda (`lambda_trigger.py`) ให้เริ่ม Glue Job | ไฟล์ต้นฉบับย้อนตรวจได้ 90 วัน (S3 Lifecycle); Glue Concurrency = 1 หากไม่ว่าง Lambda แจ้ง SNS และ Retry |
| ชั้น stg<br>(Cleaning / Curated / Redshift stg) | AWS Glue DataBrew ทำความสะอาด (ค่าว่าง ข้อมูลซ้ำ รูปแบบ) และ Glue ETL Job ตรวจ DQ01–DQ08 แปลงเป็นโครงสร้าง Star Schema เขียน Parquet ที่ `curated/batch_id=<n>/` แล้ว `COPY` เข้าตาราง `stg.*` บน Redshift; Glue Crawler ปรับ Glue Data Catalog ให้ Athena | แถวที่ไม่ผ่านกฎบันทึกใน `ops.reject_record`; คำสั่งซื้อที่มีรายการลูกถูกปฏิเสธจะถูกพักทั้งคำสั่งซื้อ |
| ชั้น dw<br>(Fact / Dimension) | `ops.sp_load_batch` ปรับมิติ SCD Type 1 สร้าง Inferred Member แทนที่ Fact ตาม Natural Key และกระทบยอด (DQ09–DQ10) ภายในธุรกรรมเดียว | จำนวนแถวและยอดรวม stg = dw; ข้อผิดพลาดใด ๆ ทำให้ ROLLBACK ทั้งรอบ |
| ชั้น mart<br>(KPI Views / Semantic) | KPI View 15 รายการใน schema `dw` และ View ช่วย `vw_sale_items`, `vw_orders`, `vw_latest_review`; `ops.sp_publish` ตรวจว่ายอด v_br01 ตรง Fact แล้วบันทึก `ops.publish_state` | เว็บและ API ได้สิทธิ์ SELECT เฉพาะ View ไม่แตะตารางฐาน |
| ชั้น Presentation | olytics-web (Next.js) บน EC2 อ่าน View ผ่าน `pg` Pool; ec2-api (Express) สำหรับการเชื่อมต่อภายใน; Query Lab สืบค้นผ่าน Redshift หรือ Amazon Athena (Glue Data Catalog) | แสดงข้อมูลของรอบที่เผยแพร่ล่าสุด; บังคับ Login และสิทธิ์ตามบทบาททุกหน้าและทุก API |

![ภาพที่ 1 ผังแสดงสถาปัตยกรรมข้อมูลและการไหลของข้อมูล (Data Architecture & Data Flow Diagram)](https://raw.githubusercontent.com/NonKaweewat/olytics-web/main/diagram/Blank_diagram.png)

**ภาพที่ 1** ผังแสดงสถาปัตยกรรมข้อมูลและการไหลของข้อมูล (Data Architecture & Data Flow Diagram)

> **คำอธิบายภาพที่ 1 และสิ่งที่ควรปรับปรุงในภาพฉบับจริง**
>
> ภาพจาก repository (`diagram/Blank_diagram.png`) แสดงลำดับ Database → S3 Raw Zone → Lambda (S3 Event Trigger) → Glue DataBrew → Glue ETL Job (Transform & Build Star Schema) → S3 Curated Zone → Amazon Redshift (Private Subnet, Security Group) เชื่อมสองทางกับ Amazon EC2 Dashboard (Public Subnet) ผ่าน SQL Port 5439 และ Internet Gateway พร้อมบริการสนับสนุน CloudWatch, CloudTrail, IAM และ SNS
>
> ภาพฉบับส่งมอบควรเพิ่ม: Amazon Athena + Glue Data Catalog/Crawler (Query Lab), Amazon Cognito User Pool (Login), AWS Secrets Manager (รหัสผ่าน Redshift และกุญแจ HMAC), ec2-api หลัง Nginx (loopback) และกล่องเส้นประ “ระยะที่ 2” สำหรับ Web Event Collector → API Gateway → Kinesis Data Firehose → S3 Raw Zone

### 2.2 องค์ประกอบระบบและเทคโนโลยี (System Stack Specification)

**ตารางที่ 11** ข้อกำหนดองค์ประกอบระบบ

| องค์ประกอบ | เทคโนโลยีและการกำหนดค่า | การควบคุม / ข้อจำกัด |
| --- | --- | --- |
| Data Lake | Amazon S3: `raw/`, `curated/` (Parquet), `athena-results/` | SSE-S3, Block Public Access, Lifecycle ตามนโยบาย Retention |
| Event Trigger | AWS Lambda (Python) จาก S3 Event Notification ที่ suffix `manifest.json` | รันพร้อมกันได้ไม่เกิน 10 Execution Environment ใน Learner Lab |
| Data Cleaning | AWS Glue DataBrew (Recipe: ลบข้อมูลซ้ำ จัดการค่าว่าง ปรับรูปแบบ) | ใช้ LabRole |
| ETL / Transformation | AWS Glue ETL Job (Python/Spark) และสคริปต์อ้างอิง `warehouse_loader.py` (pandas, Glue Python Shell) | Worker G.1X สูงสุด 10, Concurrency สูงสุด 1; ไม่ใช้ dbt/Airflow — การจัดลำดับงานใช้ S3 Event + Lambda + Glue |
| Metadata | AWS Glue Data Catalog + Glue Crawler (ฐานข้อมูล `olytics_curated`) | ให้ Athena อ่าน Curated Zone และ View ชื่อเดียวกับ Redshift |
| Data Warehouse | Amazon Redshift `ra3.large` (สูงสุด 2 Node), ฐานข้อมูล `dev`, schema `ops` `stg` `dw`; Stored Procedure plpgsql | Private Subnet; Inbound TCP 5439 จาก SG ของ EC2 เท่านั้น; PK/FK เป็นแบบ informational |
| Serverless Query | Amazon Athena Workgroup `primary` ผ่าน `@aws-sdk/client-athena` (Query Lab) | คิดค่าใช้จ่ายตามข้อมูลที่สแกน; ผลลัพธ์ที่ `ATHENA_OUTPUT_LOCATION` |
| Frontend Framework | Next.js ^15.5 (App Router, Server Components), React ^19.3, TypeScript ^5.9, Recharts ^2.15, Node.js 22 LTS | ทุกหน้า `force-dynamic` อ่านข้อมูลล่าสุดทุกคำขอ |
| Data Access | `pg` ^8.23 Pool: max 5 connections, connect timeout 8 วินาที, idle 30 วินาที, SSL; โหมดทดสอบ `@electric-sql/pglite` ^0.3 (Postgres ในหน่วยความจำ 25,000 คำสั่งซื้อจำลอง) | พารามิเตอร์ผูกค่า `$1..$n`; ชื่อ schema ตรวจด้วย Regex |
| Authentication | Amazon Cognito User Pool (`USER_PASSWORD_AUTH`, ตรวจ ID Token ด้วย `aws-jwt-verify`, Group = Role); โหมด local สำหรับทดสอบ (`DASHBOARD_USERS`) | รองรับ NEW_PASSWORD_REQUIRED; หลาย Group ได้สิทธิ์สูงสุด admin > analyst > อื่น ๆ |
| Session / Authorization | Cookie `olytics_session` ลงลายมือชื่อ HMAC-SHA256 อายุ 8 ชั่วโมง (HttpOnly, SameSite=Lax); `middleware.ts` ตรวจทุกหน้าและ API | ไม่มี Session = 401/redirect; ผิดสิทธิ์ = 403/redirect ไปหน้าหลักของบทบาท |
| Internal API | ec2-api: Express 5.3 + pg 8.23 ฟังที่ `127.0.0.1:3001`, Nginx `/api/` อนุญาตเฉพาะ loopback, systemd `olist-api.service` | SQL จาก Allowlist, Parameter Binding, Pagination สูงสุด 500 แถว, Query Timeout |
| Hosting | Amazon EC2 Amazon Linux 2023 (t3.small), pm2 หรือ systemd `olytics-web.service`, iptables 80 → 3000 | Public Subnet; Inbound HTTP 80 และ SSH 22 จาก IP ผู้ดูแล |
| Secrets | AWS Secrets Manager (Redshift, HMAC key), `.env.local` บน EC2 (ไม่ commit) | ec2-api resolve Secret ตอน runtime ผ่าน `asm-exec` ที่ตรวจ SHA-256 |
| Monitoring / Audit | Amazon CloudWatch Logs, AWS CloudTrail, Amazon SNS, `GET /api/health` | แจ้งเตือนสถานะ Pipeline สำเร็จ/ล้มเหลว |

> **[ ตำแหน่งภาพที่ 2 — ทีมงานแทรกภาพจริงที่นี่ ]**
>
> *ชนิดภาพ:* System Context / Deployment Diagram (draw.io หรือ AWS Architecture Icons)
>
> - ด้านซ้าย: ผู้ใช้ 9 บทบาท (executive, finance, category, seller, logistics, cx, marketing, analyst, admin) เข้าผ่านเบราว์เซอร์ → Internet Gateway
> - กลาง: VPC แบ่ง Public Subnet (EC2: Next.js olytics-web พอร์ต 3000 หลัง iptables 80, ec2-api 127.0.0.1:3001 หลัง Nginx) และ Private Subnet (Redshift ra3.large พอร์ต 5439)
> - ด้านขวา: บริการที่ EC2 เรียก — Amazon Cognito (InitiateAuth), Amazon Athena + Glue Data Catalog + S3 athena-results, AWS Secrets Manager
> - ด้านล่าง: Data Pipeline S3 Raw → Lambda → Glue DataBrew → Glue ETL → S3 Curated → Redshift พร้อม CloudWatch / SNS / CloudTrail
> - ระบุชั้นซอฟต์แวร์ในกล่อง EC2: middleware.ts → app/(dash) pages, app/api routes → lib/metrics → lib/scope + lib/sql → lib/db (pg Pool | PGlite mock)
> - ใส่เวอร์ชัน: Next.js 15.5, React 19.3, Node.js 22, pg 8.23, Recharts 2.15, Express 5.3 และกำกับ Security Group ทุกเส้นเชื่อม
>
> *แหล่งอ้างอิง:* code web/olytics-web/README.md, package.json, lib/redshift.ts, lib/cognito.ts, ec2-api/README.md

**ภาพที่ 2** แผนภาพโครงสร้างทางเทคโนโลยีและส่วนประกอบระบบ (Tech Stack Infrastructure & System Context Diagram)

### 2.3 รายการระบบต้นทางและสัญญาข้อมูล (Data Contracts)

ข้อมูลระยะที่ 1 ส่งเข้าระบบเป็นชุด (Batch Bundle) ตามช่วงเวลา หนึ่งชุดประกอบด้วยไฟล์ CSV ของ Olist (UTF-8 มี header) และ `manifest.json` สัญญาข้อมูลกำหนดว่าคำสั่งซื้อทุกรายการในชุดต้องมาพร้อมรายการสินค้า การชำระเงิน และรีวิวของคำสั่งซื้อนั้นครบ การแก้ไขคำสั่งซื้อย้อนหลังให้ส่งคำสั่งซื้อทั้งชุดใหม่ในชุดแก้ไขที่ครอบช่วงวันที่เดิม

**ตารางที่ 12** ระบบต้นทางและสัญญาข้อมูลระยะที่ 1 (ชุดข้อมูล Olist)

| Entity / ไฟล์ | Grain และคีย์ธุรกิจ | คอลัมน์สำคัญ | เงื่อนไขสัญญา |
| --- | --- | --- | --- |
| orders<br>`orders.csv` | หนึ่งคำสั่งซื้อ<br>`order_id` | customer_id, order_status, order_purchase_timestamp, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date | รูปแบบเวลา `YYYY-MM-DD HH:MM:SS`; วันที่สั่งซื้อต้องอยู่ในช่วง date_from–date_to |
| order_items<br>`order_items.csv` | หนึ่งรายการสินค้า<br>`order_id + order_item_id` | product_id, seller_id, shipping_limit_date, price, freight_value | ราคาและค่าส่งเป็นทศนิยม >= 0; ต้องมีคำสั่งซื้อแม่ในชุด |
| payments<br>`payments.csv` | หนึ่งรายการชำระ<br>`order_id + payment_sequential` | payment_type, payment_installments, payment_value | payment_type ∈ {credit_card, boleto, voucher, debit_card, not_defined} |
| reviews<br>`reviews.csv` | หนึ่งรีวิวต่อคำสั่งซื้อ<br>`review_id + order_id` | review_score, review_creation_date (ไม่นำเข้า review_comment_*) | คะแนน 1–5; ข้อความรีวิวไม่นำเข้าเพื่อลดข้อมูลส่วนบุคคล |
| customers<br>`customers.csv` | หนึ่งลูกค้าระดับคำสั่งซื้อ<br>`customer_id` | customer_unique_id, customer_zip_code_prefix, customer_city, customer_state | customer_unique_id ถูก Pseudonymize ก่อนเข้าคลัง; รัฐเป็นรหัส 2 ตัวอักษร |
| sellers<br>`sellers.csv` | หนึ่งผู้ขาย<br>`seller_id` | seller_zip_code_prefix, seller_city, seller_state | ส่งเฉพาะผู้ขายใหม่/เปลี่ยนแปลง (Delta) ได้ |
| products<br>`products.csv` | หนึ่งสินค้า<br>`product_id` | product_category_name (ภาษาโปรตุเกส) | ส่งแบบ Delta ได้ |
| category_translation<br>`category_translation.csv` | หนึ่งหมวด<br>`product_category_name` | product_category_name_english | ไม่บังคับ; หมวดที่ไม่มีคำแปลแสดงชื่อเดิม |

**ตารางที่ 13** ข้อกำหนด Manifest ของชุดข้อมูล (manifest.json)

| ฟิลด์ | ชนิดและเงื่อนไข | การตรวจ |
| --- | --- | --- |
| batch_name | String เช่น `2017-01` หรือ `2017-01-fix1` | ใช้ร่วมกับ SHA-256 ของ manifest เป็นคีย์ไม่ซ้ำของรอบ (Idempotent) |
| contract_version | String ปัจจุบัน `1.0` | ไม่ตรงเวอร์ชันที่รองรับ = หยุดรอบ (DQ01) |
| date_from, date_to | ISO Date ช่วงวันที่สั่งซื้อของชุด (รวมวันปลาย) | date_from &lt;= date_to; คำสั่งซื้อนอกช่วงถูกปฏิเสธ (DQ07) |
| files.&lt;entity>.file | ชื่อไฟล์ภายในโฟลเดอร์ชุด | ห้ามมี `/` หรือขึ้นต้นด้วย `.` (ป้องกันอ่านไฟล์นอกชุด) |
| files.&lt;entity>.sha256 | SHA-256 Hex 64 ตัวอักษร | ไม่ตรง = หยุดก่อนแตะคลังข้อมูล (DQ01) |
| files.&lt;entity>.row_count | จำนวนแถวข้อมูลไม่รวม header | ไม่ตรง = หยุดรอบ (DQ01) |

**ตารางที่ 14** สัญญาข้อมูลของ Web API (olytics-web และ ec2-api)

| Endpoint | คำขอ | ผลตอบกลับ | การควบคุม |
| --- | --- | --- | --- |
| `GET /api/data/{page}`<br>(olytics-web) | page ∈ overview, payments, categories, sellers, delivery, customers, marketing; query: year, month (ต้องมี year), category, region, state | JSON ตามชนิดข้อมูลของหน้า (`lib/types.ts`) รวม `ignored` = ตัวกรองที่ View ยังรองรับไม่ได้ | Session + สิทธิ์หน้า; 401/403/404/502 |
| `GET /api/filters` | — | ปีจาก v_br01, หมวดจาก v_br14, รัฐจาก v_br08 และ v_br07 | Session |
| `POST /api/query` | `{ sql }` เฉพาะ SELECT/WITH คำสั่งเดียว ใช้ `{db}.ชื่อ view` | ผลลัพธ์ไม่เกิน 50 แถว พร้อมเวลาประมวลผล | สิทธิ์ query-lab (analyst, admin); 400 เมื่อ SQL ไม่ผ่าน |
| `POST /api/login`<br>`POST /api/login/new-password`<br>`POST /api/logout` | username/email + password; รหัสใหม่ + Cognito session | ตั้ง Cookie และส่ง role, home; หรือ challenge NEW_PASSWORD_REQUIRED | ไม่ต้องมี Session; ข้อความผิดพลาดไม่เปิดเผยว่าบัญชีมีอยู่หรือไม่ |
| `GET /api/health` | — | `{ ok, source }` ทดสอบ `SELECT 1` | สาธารณะ ไม่เปิดข้อมูล |
| `GET /api/kpis/{id}`<br>(ec2-api, 15 รายการ) | year, month, state, seller_state, category, seller_id, payment_type, review_score, limit 1–500, page หรือ offset, sort, direction | `{ id, data, pagination }` ตัวเลขทศนิยม/ bigint เป็น String | loopback เท่านั้น; ตัวกรองที่ View ไม่รองรับ = 400 |

**ตารางที่ 15** สัญญาข้อมูลเหตุการณ์เว็บ (Web Event Payload) — ระยะที่ 2

| ฟิลด์ | ชนิดข้อมูล | บังคับ | ข้อกำหนด |
| --- | --- | --- | --- |
| event_id | UUID v4 (String) | ใช่ | สร้างที่ Client ใช้ตัดเหตุการณ์ซ้ำ (Idempotency Key) |
| event_type | String | ใช่ | page_view, click, search, add_to_cart, checkout_start, purchase |
| occurred_at | ISO 8601 UTC | ใช่ | เวลาที่เกิดเหตุการณ์ที่ Client; Server บันทึก received_at แยก |
| anonymous_id | String (Cookie first-party) | ใช่ | Pseudonymize ด้วย HMAC-SHA256 ก่อนเข้า Curated Zone |
| session_id | String | ใช่ | สร้างใหม่เมื่อไม่มีเหตุการณ์ 30 นาที (DQ12) |
| page_url, page_path, referrer | String | ใช่ / ไม่ | ตัด Query String ที่อาจมีข้อมูลส่วนบุคคล (email, phone, token) ก่อนส่ง |
| utm_source, utm_medium, utm_campaign | String | ไม่ | ใช้กับ Attribution ระยะที่ 2 |
| user_agent, viewport | String | ใช่ | แปลงเป็น Dim_Device (device_type, os, browser, is_bot) |
| order_id | String(32) | เฉพาะ purchase | เชื่อมกับ fact_order เพื่อคำนวณ Conversion |
| consent_analytics | Boolean | ใช่ | ส่งเหตุการณ์เฉพาะเมื่อผู้ใช้ยินยอม (Consent Management Platform) |

## 3 แบบจำลองข้อมูลและโครงสร้างคลังข้อมูล

คลังข้อมูลออกแบบตามแนวทาง Kimball แบบ Star Schema ประกอบด้วย Fact 4 ตาราง แยกตามกระบวนการธุรกิจ (คำสั่งซื้อ รายการสินค้า การชำระเงิน รีวิว) และ Dimension ร่วม 7 ตาราง ตาม ER Diagram ของโครงการ (`er diagram/Untitled_1.png`) ชนิดข้อมูล `tinyint` ใน ER Diagram ใช้ `SMALLINT` บน Redshift เนื่องจาก Redshift ไม่มีชนิด TINYINT

### 3.1 Enterprise Data Warehouse Bus Matrix

**ตารางที่ 16** Business Process และมิติร่วม (✓ = ใช้, — = ไม่ใช้, P2 = ระยะที่ 2)

| กระบวนการ (Fact) | Date | Customer | Product | Seller | Status | Payment | Review | Device | ระยะ |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| คำสั่งซื้อ (fact_order) | ✓ | ✓ | — | — | ✓ | — | — | — | 1 |
| ยอดขายรายการสินค้า (fact_order_item) | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | 1 |
| การชำระเงิน (fact_payment) | ✓ | ✓ | — | — | — | ✓ | — | — | 1 |
| รีวิวลูกค้า (fact_review) | ✓ | ✓ | — | — | — | — | ✓ | — | 1 |
| การเข้าชมเว็บ (Fact_Web_Events) | ✓ | ✓ | ✓* | ✓* | — | — | — | ✓ | P2 |
| การลงทะเบียนผู้ใช้ (Fact_User_Registration) | ✓ | ✓ | — | ✓* | — | — | — | ✓ | P2 |
| สินค้าคงคลังสิ้นวัน (Fact_Inventory_Snapshot) | ✓ | — | ✓ | ✓ | — | — | — | — | P2 |

หมายเหตุ: Customer = Dim_User, Seller = Dim_Store / Channel, Status = Order Status, Payment = Payment Method, Review = Review Score; ✓* ในระยะที่ 2 หมายถึงใช้ในบทบาท Page (Dim_Page) และ Channel

### 3.2 ข้อกำหนดมิติร่วม (Conformed Dimensions)

**ตารางที่ 17** ข้อกำหนด Conformed Dimensions

| มิติและ Grain | คอลัมน์มาตรฐาน | คีย์และนโยบายประวัติ | เจ้าของข้อมูลและการใช้ |
| --- | --- | --- | --- |
| dim_date<br>หนึ่งวัน | date_key, full_date, day_of_month, month_number, month_name, quarter_number, year_number | INT YYYYMMDD; Static; สร้างเพิ่มจากวันที่ที่พบใน Batch; −1 = Unknown | ทีมข้อมูล; ใช้ทุก Fact |
| dim_customer (Dim_User)<br>หนึ่งลูกค้าระดับคำสั่งซื้อ | customer_key, customer_id, customer_unique_id, zip_code_prefix, city, state | BIGINT SK; NK customer_id; Durable Key customer_unique_id (Pseudonymized); SCD Type 1 | ลูกค้า/การตลาด; ใช้ Order, Item, Payment, Review |
| dim_product<br>หนึ่งสินค้า | product_key, product_id, category_name, category_english | BIGINT SK; NK product_id; SCD Type 1 (เป้าหมาย SCD Type 2 ของหมวดในระยะที่ 2) | หมวดสินค้า; ใช้ Item |
| dim_seller (Dim_Store / Channel)<br>หนึ่งผู้ขาย | seller_key, seller_id, zip_code_prefix, city, state | BIGINT SK; NK seller_id; SCD Type 1; รองรับ Inferred Member | ฝ่ายดูแลผู้ขาย; ใช้ Item |
| dim_order_status<br>หนึ่งสถานะ | order_status_key, order_status | SMALLINT รหัสคงที่ 1–8; Static | ทีมข้อมูล; ใช้ Order, Item |
| dim_payment_method<br>หนึ่งวิธีชำระ | payment_method_key, payment_type | SMALLINT รหัสคงที่ 1–5; Static | การเงิน; ใช้ Payment |
| dim_review_score<br>หนึ่งคะแนน | review_score_key, review_score | SMALLINT 1–5; Static | CX; ใช้ Review |
| Dim_Device [ระยะที่ 2]<br>หนึ่งชุดอุปกรณ์ | device_key, device_type, os_family, browser_family, is_bot | BIGINT SK; NK = Hash ของ (device_type, os, browser); SCD Type 1 | การตลาด; ใช้ Web Events |
| Dim_Page [ระยะที่ 2]<br>หนึ่งหน้าเว็บ | page_key, page_path, page_group, product_id (ถ้ามี) | BIGINT SK; NK page_path ที่ตัด Query String; SCD Type 1 | การตลาด; ใช้ Web Events |

### 3.3 ทะเบียนตารางและแบบจำลองความสัมพันธ์ข้อมูล (ERD)

**ตารางที่ 18** รายการตารางในคลังข้อมูล

| ตารางและประเภท | Grain และข้อมูลที่จัดเก็บ | คีย์และการปรับข้อมูล |
| --- | --- | --- |
| dw.fact_order<br>Transaction (Header) | หนึ่งแถวต่อคำสั่งซื้อ: ยอดขาย ค่าส่ง ยอดชำระ วันจัดส่ง สถานะส่งช้า | UK order_id; Delete-Insert ตาม order_id ของ Batch; DISTKEY(order_id) |
| dw.fact_order_item<br>Transaction (Line) — Fact_Sales_Transaction | หนึ่งแถวต่อรายการสินค้าในคำสั่งซื้อ: ราคา ค่าส่ง สถานะส่งมอบทันเวลา | UK (order_id, order_item_id); แทนที่ทั้งคำสั่งซื้อเมื่อมีการแก้ไข |
| dw.fact_payment<br>Transaction | หนึ่งแถวต่อรายการชำระเงินของคำสั่งซื้อ | UK (order_id, payment_sequential) |
| dw.fact_review<br>Transaction | หนึ่งแถวต่อรีวิวต่อคำสั่งซื้อ (รีวิวเก่าเก็บไว้ View เลือกรีวิวล่าสุด) | UK (review_id, order_id) |
| dw.dim_customer / dim_seller / dim_product<br>SCD Type 1 | หนึ่งแถวต่อ Natural Key | UK Natural Key; UPDATE แล้ว INSERT; −1 = Unknown |
| dw.dim_date, dim_order_status, dim_payment_method, dim_review_score<br>Static | ปฏิทินและโดเมนคงที่ | ข้อมูลตั้งต้นใน 001_schema.sql |
| ops.load_batch / ops.reject_record / ops.publish_state / ops.state_access<br>Control | รอบโหลด จำนวนแถว ยอดกระทบ รายการไม่ผ่านกฎ รุ่นที่เผยแพร่ และสิทธิ์ระดับรัฐ | UK (batch_name, manifest_sha256) |
| stg.* (9 ตาราง)<br>Staging | ภาพข้อมูลของรอบปัจจุบันจาก S3 Curated Zone | ล้างด้วย DELETE ทุกรอบ (ไม่ใช้ TRUNCATE เพราะ Redshift จะ COMMIT ทันที) |
| dw.v_br01 … v_br14 (15 View) และ vw_*<br>Semantic / Mart | KPI สำเร็จรูปสำหรับเว็บ API และ Athena | สร้างใหม่ด้วย CREATE OR REPLACE VIEW |
| Fact_Web_Events [ระยะที่ 2]<br>Transaction (Event) | หนึ่งแถวต่อเหตุการณ์เว็บ | UK event_id; Append + Dedup |

![ภาพที่ 3 แผนภาพความสัมพันธ์ตารางข้อมูลคลังข้อมูลการวิเคราะห์เว็บและการขาย (ERD Diagram)](https://raw.githubusercontent.com/NonKaweewat/olytics-web/main/er%20diagram/Untitled_1.png)

**ภาพที่ 3** แผนภาพความสัมพันธ์ตารางข้อมูลคลังข้อมูลการวิเคราะห์เว็บและการขาย (ERD Diagram)

> **คำอธิบายภาพที่ 3**
>
> ภาพจาก repository (`er diagram/Untitled_1.png`, dbdiagram.io) แสดง Star Schema ของระยะที่ 1: fact_order, fact_order_item, fact_payment และ fact_review เชื่อม dim_date, dim_customer, dim_seller, dim_product, dim_order_status, dim_payment_method และ dim_review_score
>
> ภาพฉบับส่งมอบควรเพิ่มกลุ่มเส้นประ “ระยะที่ 2”: Fact_Web_Events เชื่อม dim_date, dim_customer (เมื่อผู้ใช้ Login), Dim_Device, Dim_Page และ dim_seller (Channel) พร้อมเส้นเชื่อมเชิงตรรกะ Fact_Web_Events.order_id → fact_order.order_id และแสดงคอลัมน์ load_batch_id ของทุก Fact

### 3.4 โครงสร้างตารางข้อเท็จจริง (Fact Tables Details)

#### 3.4.1 dw.fact_order_item (Fact_Sales_Transaction)

หนึ่งแถวต่อรายการสินค้าในคำสั่งซื้อ เป็น Fact หลักของยอดขาย (M01, M03, M05, M07, M15) และเป็นฐานของ View ส่วนใหญ่ผ่าน `vw_sale_items`

**ตารางที่ 19** โครงสร้าง fact_order_item

| คอลัมน์ | ชนิดข้อมูล | Key / บทบาท | Null | ข้อกำหนด |
| --- | --- | --- | --- | --- |
| order_item_key | BIGINT | PK | ไม่ได้ | IDENTITY; คีย์ภายในคลัง |
| order_id | VARCHAR(32) | UK ส่วนที่ 1 / DD | ไม่ได้ | รหัสคำสั่งซื้อ Olist; DISTKEY |
| order_item_id | INT | UK ส่วนที่ 2 | ไม่ได้ | ลำดับรายการในคำสั่งซื้อ (1, 2, 3 …) |
| purchase_date_key | INT | FK dim_date | ไม่ได้ | YYYYMMDD จากวันที่สั่งซื้อ; SORTKEY |
| customer_key | BIGINT | FK dim_customer | ไม่ได้ | Lookup ตาม customer_id ของคำสั่งซื้อ; ไม่พบ = Inferred Member |
| seller_key | BIGINT | FK dim_seller | ไม่ได้ | Lookup seller_id; ไม่พบ = Inferred Member (เติม Attribute เมื่อ Master มาถึง) |
| product_key | BIGINT | FK dim_product | ไม่ได้ | Lookup product_id; ไม่พบ = Inferred Member |
| order_status_key | SMALLINT | FK dim_order_status | ไม่ได้ | สถานะของคำสั่งซื้อแม่ ใช้ตัด canceled/unavailable จากยอดขาย |
| price | DECIMAL(12,2) | Additive | ไม่ได้ | ราคาสินค้า R$ >= 0 (M01) |
| freight_value | DECIMAL(12,2) | Additive | ไม่ได้ | ค่าขนส่งของรายการ R$ >= 0 |
| item_count | SMALLINT | Additive | ไม่ได้ | ค่าคงที่ 1 ต่อแถว (M03) |
| on_time_flag | SMALLINT | Flag | ได้ | 1 = ส่งมอบขนส่งก่อน shipping_limit_date, 0 = เลยกำหนด, NULL = ไม่มีวันส่งมอบ (M07) |
| load_batch_id | BIGINT | Metadata | ไม่ได้ | อ้างอิง ops.load_batch เพื่อ Lineage [ออกแบบในเอกสารนี้] |

#### 3.4.2 dw.fact_order

**ตารางที่ 20** โครงสร้าง fact_order

| คอลัมน์ | ชนิดข้อมูล | Key / บทบาท | Null | ข้อกำหนด |
| --- | --- | --- | --- | --- |
| order_key | BIGINT | PK | ไม่ได้ | IDENTITY |
| order_id | VARCHAR(32) | UK / DD | ไม่ได้ | หนึ่งแถวต่อคำสั่งซื้อ; DISTKEY |
| purchase_date_key | INT | FK dim_date | ไม่ได้ | วันที่สั่งซื้อ; SORTKEY |
| customer_key | BIGINT | FK dim_customer | ไม่ได้ | ลูกค้าของคำสั่งซื้อ |
| order_status_key | SMALLINT | FK dim_order_status | ไม่ได้ | สถานะล่าสุดของคำสั่งซื้อ (M12) |
| total_sales | DECIMAL(14,2) | Additive | ได้ | ผลรวม price ของรายการในคำสั่งซื้อ (0.00 เมื่อไม่มีรายการ) |
| total_freight | DECIMAL(14,2) | Additive | ได้ | ผลรวม freight_value (M16) |
| total_payment | DECIMAL(14,2) | Additive | ได้ | ผลรวม payment_value; ต่างจาก sales + freight เกิน 0.01 = คำเตือน DQ06 |
| order_count | SMALLINT | Additive | ไม่ได้ | ค่าคงที่ 1 |
| delivery_days | DECIMAL(10,2) | Semi-additive | ได้ | วันจัดส่งเมื่อสถานะ delivered และวันที่ส่งถึง >= วันที่สั่ง (M10); รวมผ่าน sum_delivery_days เท่านั้น |
| late_flag | SMALLINT | Flag | ได้ | 1 = ส่งถึงช้ากว่าวันประมาณการ, 0 = ทันเวลา, NULL = ยังไม่ส่งถึง (M09) |
| load_batch_id | BIGINT | Metadata | ไม่ได้ | รอบโหลดล่าสุดที่เขียนแถวนี้ |

#### 3.4.3 dw.fact_payment และ dw.fact_review

**ตารางที่ 21** โครงสร้าง fact_payment และ fact_review

| ตาราง.คอลัมน์ | ชนิดข้อมูล | Key / บทบาท | Null | ข้อกำหนด |
| --- | --- | --- | --- | --- |
| fact_payment.payment_key | BIGINT | PK | ไม่ได้ | IDENTITY |
| fact_payment.order_id + payment_sequential | VARCHAR(32) + SMALLINT | UK | ไม่ได้ | หนึ่งคำสั่งซื้อชำระได้หลายครั้ง (เช่น voucher + credit_card) |
| fact_payment.purchase_date_key / customer_key | INT / BIGINT | FK | ไม่ได้ | วันที่และลูกค้าของคำสั่งซื้อ |
| fact_payment.payment_method_key | SMALLINT | FK dim_payment_method | ไม่ได้ | วิธีชำระ (M06) |
| fact_payment.payment_installments | SMALLINT | Non-additive | ไม่ได้ | จำนวนงวดผ่อน |
| fact_payment.payment_value | DECIMAL(12,2) | Additive | ไม่ได้ | มูลค่าชำระ R$ >= 0 |
| fact_review.review_key | BIGINT | PK | ไม่ได้ | IDENTITY; ใช้ตัดสินรีวิวล่าสุดเมื่อวันที่เท่ากัน |
| fact_review.review_id + order_id | VARCHAR(32) ×2 | UK | ไม่ได้ | Olist มี review_id เดียวผูกหลายคำสั่งซื้อได้ จึงใช้คู่คีย์ |
| fact_review.review_date_key | INT | FK dim_date | ไม่ได้ | วันที่สร้างรีวิว; ใช้นับเดือนของ M08 |
| fact_review.review_score_key | SMALLINT | FK dim_review_score | ไม่ได้ | คะแนน 1–5 |
| fact_review.review_count | SMALLINT | Additive | ไม่ได้ | ค่าคงที่ 1 |

#### 3.4.4 Fact_Web_Events [ระยะที่ 2]

ตารางนี้เป็นแบบออกแบบสำหรับระยะที่ 2 ยังไม่มีข้อมูลต้นทางในชุดข้อมูล Olist Grain คือหนึ่งแถวต่อเหตุการณ์เว็บที่ผ่านการตัดซ้ำตาม `event_id` และผู้ใช้ให้ความยินยอมด้านการวิเคราะห์แล้ว

**ตารางที่ 22** โครงสร้าง Fact_Web_Events (ออกแบบระยะที่ 2)

| คอลัมน์ | ชนิดข้อมูล | Key / บทบาท | Null | ข้อกำหนด |
| --- | --- | --- | --- | --- |
| event_key | BIGINT | PK | ไม่ได้ | IDENTITY |
| event_id | CHAR(36) | UK | ไม่ได้ | UUID จาก Client; ซ้ำ = เก็บแถวแรก |
| event_date_key | INT | FK dim_date | ไม่ได้ | วันที่ตามเวลา Asia/Bangkok ของ occurred_at |
| event_ts | TIMESTAMPTZ | Attribute | ไม่ได้ | เวลาเกิดเหตุการณ์ (UTC) |
| session_id | VARCHAR(64) | Degenerate | ไม่ได้ | Session ตามกฎหมดเวลา 30 นาที (DQ12) |
| visitor_pseudo_id | CHAR(32) | Degenerate | ไม่ได้ | HMAC-SHA256 ของ anonymous_id (W02) |
| customer_key | BIGINT | FK dim_customer | ไม่ได้ | −1 เมื่อไม่ได้ Login |
| page_key / device_key / channel_key | BIGINT | FK Dim_Page / Dim_Device / dim_seller | ไม่ได้ | −1 เมื่อ Lookup ไม่สำเร็จ |
| event_type | VARCHAR(30) | Attribute | ไม่ได้ | page_view, click, search, add_to_cart, checkout_start, purchase |
| order_id | VARCHAR(32) | Degenerate | ได้ | เฉพาะ purchase; เชื่อม fact_order (W05) |
| engaged_flag | SMALLINT | Flag | ไม่ได้ | 1 เมื่อเป็นเหตุการณ์โต้ตอบ ใช้คำนวณ Bounce (W04) |
| event_count | SMALLINT | Additive | ไม่ได้ | ค่าคงที่ 1 (W01) |
| load_batch_id | BIGINT | Metadata | ไม่ได้ | รอบโหลด |

### 3.5 โครงสร้างตารางมิติ (Dimension Tables Details)

#### 3.5.1 dw.dim_customer (Dim_User)

ชุดข้อมูล Olist ออก `customer_id` ใหม่ทุกคำสั่งซื้อ และใช้ `customer_unique_id` แทนตัวบุคคล ข้อมูลต้นทางไม่มีชื่อ อีเมล หรือเบอร์โทรศัพท์ ข้อมูลที่ใกล้เคียงข้อมูลส่วนบุคคลได้แก่รหัสบุคคล และรหัสไปรษณีย์ 5 หลักแรก จึงกำหนดมาตรการตามตารางด้านล่าง

**ตารางที่ 23** โครงสร้าง dim_customer และฟิลด์ที่เกี่ยวกับ PDPA

| คอลัมน์ | ชนิดข้อมูล | Key / บทบาท | Null | ข้อกำหนดและมาตรการคุ้มครอง |
| --- | --- | --- | --- | --- |
| customer_key | BIGINT | PK | ไม่ได้ | IDENTITY; −1 = Unknown |
| customer_id | VARCHAR(32) | NK | ไม่ได้ | รหัสลูกค้าระดับคำสั่งซื้อ; ไม่เปิดใน View ของนักวิเคราะห์ |
| customer_unique_id | VARCHAR(32) | Durable Key | ไม่ได้ | **Pseudonymized**: HMAC-SHA256(กุญแจลับใน Secrets Manager, ค่าเดิม) ตัด 32 hex ตั้งแต่ขั้น ETL; Inferred Member ใช้ customer_id แทนชั่วคราว |
| zip_code_prefix | VARCHAR(5) | Attribute (จำกัดสิทธิ์) | ได้ | เติม 0 ด้านหน้าให้ครบ 5 หลัก; View `v_user_analytics` แสดงเพียง 2 หลัก + `xxx` |
| city | VARCHAR(100) | Attribute | ได้ | เมืองของลูกค้า (BR13) |
| state | CHAR(2) | Attribute | ได้ | รหัสรัฐ 27 รัฐ; ไม่ถูกต้อง = NULL พร้อมคำเตือน DQ05 |

#### 3.5.2 dw.dim_product, dw.dim_seller (Dim_Store / Channel) และ dw.dim_date

**ตารางที่ 24** โครงสร้าง dim_product, dim_seller และ dim_date

| ตาราง.คอลัมน์ | ชนิดข้อมูล | Key / บทบาท | Null | ข้อกำหนด |
| --- | --- | --- | --- | --- |
| dim_product.product_key | BIGINT | PK | ไม่ได้ | IDENTITY; −1 = Unknown |
| dim_product.product_id | VARCHAR(32) | NK | ไม่ได้ | รหัสสินค้า Olist |
| dim_product.category_name | VARCHAR(100) | Attribute | ได้ | หมวดภาษาโปรตุเกส; NULL ใน Inferred Member |
| dim_product.category_english | VARCHAR(100) | Attribute | ได้ | คำแปลจาก category_translation; View ใช้ COALESCE(english, name) |
| dim_seller.seller_key | BIGINT | PK | ไม่ได้ | IDENTITY; −1 = Unknown (ไม่ถูกนับใน M13) |
| dim_seller.seller_id | VARCHAR(32) | NK | ไม่ได้ | รหัสผู้ขาย |
| dim_seller.zip_code_prefix / city / state | VARCHAR(5) / VARCHAR(100) / CHAR(2) | Attribute | ได้ | ที่ตั้งผู้ขาย ใช้ตัวกรองรัฐผู้ขายและภาค (BR05–BR07) |
| dim_date.date_key | INT | PK | ไม่ได้ | YYYYMMDD; −1 = Unknown (1900-01-01) |
| dim_date.full_date | DATE | UK | ไม่ได้ | วันที่ปฏิทิน |
| dim_date.day_of_month / month_number / quarter_number / year_number | SMALLINT | Attribute | ไม่ได้ | ค่าตามปฏิทินเกรกอเรียน (ค.ศ.) |
| dim_date.month_name | VARCHAR(15) | Attribute | ไม่ได้ | ชื่อเดือนภาษาอังกฤษ (January … December) |

ภาคของบราซิล 5 ภาค (North, Northeast, Central-West, Southeast, South) ไม่เก็บในคลังข้อมูล แต่เว็บจัดกลุ่มจากรหัสรัฐตามตารางของ IBGE ใน `lib/regions.ts` และแปลงเป็นนิพจน์ `CASE` ใน SQL (`regionCase()`) เพื่อใช้กรองและสรุปผล

### 3.6 ข้อกำหนดการจัดการประวัติข้อมูล (SCD Policy)

**ตารางที่ 25** นโยบายประวัติรายมิติ

| ตารางและคอลัมน์ | การใช้งานปัจจุบัน (ระยะที่ 1) | ข้อกำหนดเป้าหมาย / ผลต่อการรายงาน |
| --- | --- | --- |
| dim_customer<br>zip, city, state | SCD Type 1 ตาม customer_id; ประวัติที่อยู่ ณ เวลาซื้อถูกเก็บโดยธรรมชาติ เพราะ Olist ออก customer_id ใหม่ทุกคำสั่งซื้อ (เทียบเท่า SCD Type 2 บน Durable Key customer_unique_id) | ระยะที่ 2 เมื่อมีบัญชีผู้ใช้เว็บถาวร: SCD Type 2 บน customer_unique_id เพิ่ม effective_start_date, effective_end_date ([start, end)), is_current; Lookup ตามวันที่ธุรกรรม |
| dim_product<br>category_name, category_english | SCD Type 1 (แก้หมวดย้อนหลังทุกรายการขาย) | ระยะที่ 2: SCD Type 2 ของหมวดสินค้า เพื่อรายงานยอดขายตามหมวด ณ วันขาย; ช่วงของ NK เดียวกันห้ามทับซ้อน |
| dim_seller<br>zip, city, state | SCD Type 1 และ Inferred Member (คง Surrogate Key เมื่อ Master มาถึงภายหลัง) | คงนโยบาย Type 1; การวิเคราะห์ภาคใช้ที่ตั้งปัจจุบัน |
| dim_date, dim_order_status, dim_payment_method, dim_review_score | Static: รหัสคงที่ เพิ่มได้ ห้ามเปลี่ยนความหมาย | ค่าโดเมนใหม่ต้องเพิ่มใน 001_schema.sql และ Data Contract ก่อน มิฉะนั้นถูกปฏิเสธด้วย DQ05 |
| ทุกตารางมิติ | สมาชิก Unknown รหัส −1 สร้างใน Bootstrap (batch_id 0) | View ที่นับมิติ (เช่น M13) ต้องตัด −1 ออก |
| Dim_Device, Dim_Page [ระยะที่ 2] | — | SCD Type 1; การจัดกลุ่มหน้าเปลี่ยนได้โดยไม่สร้างเวอร์ชัน |

## 4 กระบวนการรับ แปลง และโหลดข้อมูล

กระบวนการเริ่มเมื่อ `manifest.json` ของชุดข้อมูลถูกอัปโหลดเข้า S3 Raw Zone: Lambda เรียก Glue Job, Glue ตรวจ Manifest และคุณภาพข้อมูล แปลงข้อมูลเป็นตาราง Staging เขียน Parquet ลง Curated Zone แล้วส่งชุดคำสั่ง SQL ผ่าน Amazon Redshift Data API เป็น **ธุรกรรมเดียว** (`batch_execute_statement`) ประกอบด้วย COPY เข้า stg, `CALL ops.sp_load_batch` และ `CALL ops.sp_publish` หากขั้นใดล้มเหลว ธุรกรรมทั้งหมด ROLLBACK และ Dashboard ยังอ่านข้อมูลรุ่นที่เผยแพร่ก่อนหน้า การใช้ Data API ทำให้ Glue ไม่ต้องถือรหัสผ่านหรือ Driver ฐานข้อมูล และทำงานได้ด้วยสิทธิ์ LabRole

### 4.1 Source to Target Mapping

**ตารางที่ 26** Mapping ของ fact_order_item (Fact_Sales_Transaction)

| คอลัมน์ปลายทาง | แหล่งข้อมูล | Transformation และ Lookup |
| --- | --- | --- |
| order_id, order_item_id | order_items.order_id, order_item_id | TRIM; order_item_id ต้องเป็นจำนวนเต็ม (DQ03); คู่คีย์ไม่ซ้ำ (DQ04) |
| purchase_date_key | orders.order_purchase_timestamp | แปลงเป็น DATE แล้ว Lookup dim_date.full_date; ปฏิทินเพิ่มจาก stg.calendar ก่อนโหลด Fact |
| customer_key | orders.customer_id (ผ่าน order_id) | Lookup dim_customer.customer_id; ไม่พบ = สร้าง Inferred Member (customer_unique_id = customer_id ชั่วคราว) |
| seller_key | order_items.seller_id | Lookup dim_seller.seller_id; ไม่พบ = Inferred Member แล้วเติม Attribute เมื่อ sellers.csv มาถึง |
| product_key | order_items.product_id | Lookup dim_product.product_id; ไม่พบ = Inferred Member |
| order_status_key | orders.order_status | INNER JOIN dim_order_status (โดเมนตรวจแล้วใน DQ05) |
| price, freight_value | order_items.price, freight_value | Decimal ปัดเศษ ROUND_HALF_UP 2 ตำแหน่ง; ต้อง >= 0 (DQ06) |
| item_count | ค่าคงที่ | 1 |
| on_time_flag | orders.order_delivered_carrier_date, order_items.shipping_limit_date | NULL เมื่อไม่มีวันส่งมอบขนส่ง; 1 เมื่อ carrier_date &lt;= shipping_limit_date; มิฉะนั้น 0 |
| load_batch_id | ops.load_batch.batch_id | รอบโหลดปัจจุบัน |

**ตารางที่ 27** Mapping ของ fact_order, fact_payment และ fact_review

| ปลายทาง | แหล่งข้อมูล | Transformation |
| --- | --- | --- |
| fact_order.total_sales / total_freight | SUM ของ order_items.price / freight_value ต่อ order_id | 0.00 เมื่อคำสั่งซื้อไม่มีรายการ (เช่น unavailable) |
| fact_order.total_payment | SUM ของ payments.payment_value ต่อ order_id | เทียบกับ sales + freight; ต่างเกิน 0.01 = WARNING DQ06 (เช่น voucher) |
| fact_order.delivery_days | order_delivered_customer_date − order_purchase_timestamp | หน่วยวัน 2 ตำแหน่ง เฉพาะ delivered; วันที่ส่งถึงก่อนวันสั่ง = NULL + WARNING DQ07 |
| fact_order.late_flag | order_delivered_customer_date, order_estimated_delivery_date | เทียบระดับวันที่: ส่งถึง > ประมาณการ = 1, มิฉะนั้น 0; NULL เมื่อยังไม่ส่งถึง |
| fact_payment.* | payments.csv + orders (customer_id, วันที่สั่ง) | payment_type → dim_payment_method; payment_sequential, installments เป็นจำนวนเต็ม (DQ03) |
| fact_review.* | reviews.csv + orders (customer_id) | review_creation_date → review_date_key; review_score → dim_review_score; ไม่นำเข้าข้อความรีวิว |

**ตารางที่ 28** Mapping ของตารางมิติ

| ปลายทาง | ระบบและคอลัมน์ต้นทาง | การแปลงและการโหลด |
| --- | --- | --- |
| dim_customer | customers: customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state | HMAC-SHA256 customer_unique_id → 32 hex; zip เติม 0 ให้ครบ 5 หลัก; รัฐไม่ถูกต้อง = NULL; UPDATE ตาม NK แล้ว INSERT |
| dim_seller | sellers: seller_id, seller_zip_code_prefix, seller_city, seller_state | เช่นเดียวกับลูกค้า (ไม่ Pseudonymize เพราะเป็นข้อมูลนิติบุคคล/ร้านค้า) |
| dim_product | products.product_id, product_category_name + category_translation | category_english จากตารางแปล; ไม่มีคำแปล = NULL |
| dim_date | วันที่สั่งซื้อและวันที่รีวิวที่พบใน Batch | สร้าง date_key YYYYMMDD, เดือน ไตรมาส ปี และชื่อเดือนภาษาอังกฤษ; เพิ่มเฉพาะวันที่ยังไม่มี |

### 4.2 เงื่อนไขคุณภาพข้อมูล (Data Quality Rules)

**ตารางที่ 29** Data Quality Rules (DQ01–DQ12)

| รหัสและการตรวจ | เกณฑ์ผ่าน | การจัดการเมื่อไม่ผ่าน | ตำแหน่ง / ผู้รับผิดชอบ |
| --- | --- | --- | --- |
| DQ01 Manifest และ Checksum | Manifest ครบฟิลด์ contract_version ตรง SHA-256 และจำนวนแถวของทุกไฟล์ตรง | หยุดรอบก่อนแตะคลังข้อมูล บันทึก FAILED + error_message และแจ้ง SNS | Glue `read_frames()` / วิศวกรข้อมูล |
| DQ02 Schema Check | คอลัมน์บังคับของทุก Entity ครบ | หยุดรอบ | Glue / วิศวกรข้อมูล |
| DQ03 ชนิดข้อมูล | Timestamp, ตัวเลข และจำนวนเต็มแปลงได้ | แถวผิด REJECTED (ระบุ Entity และลำดับแถว) | Glue / เจ้าของข้อมูลต้นทาง |
| DQ04 Business Key Unique และ Deduplication | คีย์ธุรกิจไม่ว่างและไม่ซ้ำ | ซ้ำทั้งแถวเก็บแถวแรก (นับ deduplicated); คีย์ซ้ำแต่ข้อมูลต่าง = CONFLICT ทั้งกลุ่ม | Glue `dedupe()` / เจ้าของข้อมูลต้นทาง |
| DQ05 Domain | order_status, payment_type, review_score 1–5, รัฐ 2 ตัวอักษร | สถานะ/วิธีชำระ/คะแนนผิด = REJECTED; รัฐผิด = เก็บ NULL + WARNING | Glue / เจ้าของข้อมูล |
| DQ06 Monetary Balance | price, freight, payment >= 0; ยอดชำระ ≈ สินค้า + ค่าส่ง (±0.01) | ค่าติดลบ = REJECTED; ยอดไม่สมดุล = WARNING (ไม่แก้ตัวเลขเอง) | Glue / การเงิน |
| DQ07 Temporal Validity | วันที่สั่งซื้ออยู่ในช่วง Manifest; วันที่ส่งถึง >= วันที่สั่ง | นอกช่วง = REJECTED; ส่งถึงก่อนสั่ง = delivery_days NULL + WARNING | Glue / เจ้าของข้อมูล |
| DQ08 Referential ภายในชุด | รายการสินค้า/ชำระ/รีวิวมีคำสั่งซื้อแม่ที่ผ่าน; ลูกค้าของคำสั่งซื้ออยู่ในชุด | ลูกไม่มีแม่ = REJECTED; ลูกถูกปฏิเสธ = พักทั้งคำสั่งซื้อ; ไม่มีลูกค้า = WARNING + Inferred Member | Glue / วิศวกรข้อมูล |
| DQ09 Temporal Lookup Integrity | Fact ทุกแถว Lookup วันที่ได้; มิติที่ยังไม่มีถูกสร้างเป็น Inferred Member | date_key = −1 แม้หนึ่งแถว = RAISE EXCEPTION และ ROLLBACK | `ops.sp_load_batch` / วิศวกรข้อมูล |
| DQ10 Reconciliation | จำนวนแถวและยอดเงิน stg = dw สำหรับ order, item (price), payment (value), review; คีย์ไม่ซ้ำใน Fact | RAISE EXCEPTION, ROLLBACK, FAILED; แสดงยอดทั้งสองฝั่งใน error_message | `ops.sp_load_batch` / การเงินและทีมข้อมูล |
| DQ11 Replay / Idempotency | Manifest เดิมที่ PUBLISHED ไม่ถูกโหลดซ้ำ; รอบที่ FAILED รันใหม่ได้ | ข้ามรอบและคืน batch_id เดิม | `register_batch()` / วิศวกรข้อมูล |
| DQ12 Session Timeout Verification [ระยะที่ 2] | เหตุการณ์ใน Session เดียวห่างกันไม่เกิน 30 นาที และไม่ข้ามวันตามเวลา Asia/Bangkok; event_id ไม่ซ้ำ | แยก Session ใหม่ (Sessionization ฝั่งเซิร์ฟเวอร์) และบันทึกจำนวน Session ที่ถูกแยก | Glue Web Events / การตลาด |

> **[ ตำแหน่งภาพที่ 4 — ทีมงานแทรกภาพจริงที่นี่ ]**
>
> *ชนิดภาพ:* Flowchart แนวตั้ง (BPMN หรือ draw.io) แบ่ง Swimlane: S3 / Lambda / Glue / Redshift / ผู้ดูแล
>
> - เริ่ม: อัปโหลดไฟล์ CSV → อัปโหลด manifest.json (ไฟล์สุดท้าย) → S3 Event → Lambda ตรวจ Key `raw/batch=<name>/manifest.json`
> - Decision: Glue ว่างหรือไม่ — ไม่ว่าง → SNS แจ้ง + Lambda Retry
> - Glue: อ่าน Manifest → register_batch (RECEIVED) → Decision PUBLISHED แล้ว? → ใช่ = จบ (DQ11)
> - Glue: DQ01 Checksum/Row Count → DQ02 Schema → (ล้ม = FAILED + SNS) → DQ03–DQ08 แยก Accepted / Rejected / Conflict / Warning / Deduplicated
> - Glue: เขียน Parquet ไป S3 Curated Zone → Redshift Data API ธุรกรรมเดียว: DELETE+COPY stg.* → reject_record → sp_load_batch (มิติ, Inferred Member, Fact, DQ09–DQ10) → sp_publish
> - Decision: ธุรกรรมสำเร็จ? → ใช่ = PUBLISHED + SNS สรุปจำนวน; ไม่ = ROLLBACK → FAILED + reject_record + SNS → ผู้ดูแลแก้ต้นทาง/กฎ แล้วรันซ้ำ
> - แสดงสถานะ ops.load_batch ที่แต่ละจุด: RECEIVED → VALIDATED → LOADED → PUBLISHED / FAILED
>
> *แหล่งอ้างอิง:* ภาคผนวก ค (warehouse_loader.py, lambda_trigger.py) และภาคผนวก ข (ops.sp_load_batch, ops.sp_publish)

**ภาพที่ 4** ผังกระบวนการโหลดข้อมูลและการตรวจคุณภาพ (ETL Pipeline & Data Quality Flowchart)

### 4.3 กลยุทธ์การโหลดข้อมูลและการควบคุม Transaction (Load Strategy & Recovery)

**ตารางที่ 30** กลยุทธ์การโหลดแยกตามปลายทาง

| ปลายทาง | โหลดตั้งต้น | รอบถัดไปและการแก้ไข |
| --- | --- | --- |
| S3 Raw / Curated | อัปโหลดชุดข้อมูลตามลำดับเวลา (เช่น 2016-09 … 2018-10) | ไฟล์ต้นฉบับไม่แก้ไข; Curated เขียนทับเฉพาะ `batch_id=<n>/` |
| stg.* | DELETE แล้ว COPY ทุกรอบภายในธุรกรรม | ไม่ใช้ TRUNCATE (Redshift COMMIT ทันที ทำให้ ROLLBACK ไม่ได้) |
| มิติ SCD Type 1 | INSERT หนึ่งแถวต่อ NK | UPDATE ตาม NK แล้ว INSERT รายการใหม่; Inferred Member ได้ Attribute เมื่อ Master มาถึงโดยคง Surrogate Key |
| dim_date และโดเมน | Bootstrap ใน 001_schema.sql | เพิ่มเฉพาะวันที่ใหม่จาก stg.calendar |
| Fact ทั้ง 4 ตาราง | INSERT พร้อม Lookup มิติ | Delete-Insert ตาม order_id (และ review_id + order_id) — การแก้คำสั่งซื้อต้องส่งทั้งคำสั่งซื้อในชุดแก้ไขที่ครอบช่วงวันที่เดิม |
| KPI Views | CREATE OR REPLACE VIEW | View อ่านข้อมูลล่าสุดทันทีเมื่อธุรกรรม COMMIT; sp_publish ตรวจ v_br01 = Fact ก่อนเผยแพร่ |
| การยกเลิกคำสั่งซื้อ | — | ส่งคำสั่งซื้อเดิมพร้อม order_status = canceled ในชุดแก้ไข ระบบจะแทนที่และ View ตัดออกจากยอดขายเอง |

**ตารางที่ 31** โครงสร้าง ops.load_batch

| คอลัมน์ | ชนิดข้อมูล | Null | ข้อกำหนด |
| --- | --- | --- | --- |
| batch_id | BIGINT IDENTITY | ไม่ได้ | PK; batch 0 = Bootstrap สมาชิกพิเศษ |
| batch_name, manifest_sha256 | VARCHAR(100), CHAR(64) | ไม่ได้ | UNIQUE คู่กัน ใช้ตรวจ Replay (DQ11) |
| contract_version, source_prefix | VARCHAR(20), VARCHAR(1024) | ไม่ได้ | เวอร์ชันสัญญาข้อมูลและตำแหน่ง S3 ของชุด |
| business_date_from, business_date_to | DATE | ไม่ได้ | ช่วงวันที่สั่งซื้อของชุด (รวมวันปลาย) |
| status | VARCHAR(20) | ไม่ได้ | RECEIVED → VALIDATED → LOADED → PUBLISHED หรือ FAILED |
| raw / accepted / rejected / deduplicated / warning_row_count | BIGINT | ไม่ได้ | จำนวนแถวแยกตามผลการตรวจ (นับแถวไม่ซ้ำแม้ผิดหลายกฎ) |
| inferred_member_count | BIGINT | ไม่ได้ | จำนวนรหัสมิติที่ถูกสร้างล่วงหน้าในรอบนี้ |
| source/target_sales_amount, source/target_payment_amount | DECIMAL(18,2) | ได้ | ยอดกระทบระหว่าง stg และ dw (DQ10) |
| started_at, finished_at | TIMESTAMP | ไม่ได้ / ได้ | เวลาเริ่มและเวลาเผยแพร่หรือล้มเหลว |
| error_message | VARCHAR(4000) | ได้ | สาเหตุโดยย่อ ไม่บันทึกข้อมูลส่วนบุคคลหรือรหัสผ่าน |

**ตารางที่ 32** โครงสร้าง ops.reject_record

| คอลัมน์ | ชนิดข้อมูล | Null | ข้อกำหนด |
| --- | --- | --- | --- |
| reject_id | BIGINT IDENTITY | ไม่ได้ | PK |
| batch_id | BIGINT | ไม่ได้ | FK ops.load_batch |
| entity_type | VARCHAR(30) | ไม่ได้ | orders, order_items, payments, reviews, customers, sellers, products |
| source_row_number | BIGINT | ไม่ได้ | ลำดับแถวในไฟล์ (ไม่รวม header) เพื่อย้อนกลับไปแก้ต้นทาง |
| business_key | VARCHAR(200) | ได้ | คีย์ธุรกิจคั่นด้วย `\|` เช่น order_id\|order_item_id |
| rule_code | VARCHAR(10) | ไม่ได้ | DQ01–DQ12 |
| record_status | VARCHAR(20) | ไม่ได้ | REJECTED, CONFLICT, WARNING, RESOLVED |
| error_detail | VARCHAR(1000) | ไม่ได้ | คำอธิบายสาเหตุ ไม่คัดลอกค่าข้อมูลส่วนบุคคล |
| resolved_batch_id | BIGINT | ได้ | รอบที่นำรายการกลับเข้าระบบได้ |

**ตารางที่ 33** ลำดับประมวลผลและการกู้คืน

| ขั้นตอน | เงื่อนไขสำเร็จ | การกู้คืน |
| --- | --- | --- |
| 1 รับ Manifest และลงทะเบียน | Manifest อ่านได้; บันทึก RECEIVED (LOCK ops.load_batch) | อ่าน Manifest ไม่ได้ = ไม่ลงทะเบียน แจ้งผู้ส่งข้อมูล |
| 2 ตรวจ DQ01–DQ08 | Checksum ครบ; แยก Accepted / Rejected / Conflict / Warning | FAILED พร้อมรายการ reject; แก้ต้นทางแล้วส่ง Manifest ใหม่ หรือรัน Manifest เดิมซ้ำเมื่อแก้กฎ |
| 3 Staging | COPY ทุกตาราง stg สำเร็จ | อยู่ในธุรกรรมเดียวกับขั้น 4–6 |
| 4 โหลดมิติและ Fact | ไม่มีคีย์ซ้ำ; Lookup วันที่สำเร็จ | ROLLBACK ทั้งธุรกรรม |
| 5 กระทบยอด (DQ10) | stg = dw ทั้งจำนวนแถวและยอดเงิน | ROLLBACK; ตรวจ Join ที่ทำให้แถวหาย/ซ้ำจาก error_message |
| 6 เผยแพร่ | v_br01 = Fact; บันทึก publish_state | รุ่นที่เผยแพร่ก่อนหน้ายังใช้งานได้ (ข้อมูลไม่เปลี่ยน) |
| Backfill / โหลดย้อนหลัง | ส่งชุดแก้ไขช่วงวันที่เดิม เช่น `2017-01-fix1` | Delete-Insert ตาม order_id ทำให้ผลลัพธ์เหมือนโหลดครั้งแรก |
| กู้คืนคลังข้อมูลทั้งหมด | Redshift Automated Snapshot | Restore Snapshot แล้ว Replay ชุดที่ PUBLISHED หลังเวลา Snapshot ตามลำดับ batch_id จาก Raw Zone |

## 5 การกำกับดูแล ความปลอดภัย และสิทธิ์การใช้งาน

การควบคุมสิทธิ์มีสามชั้น ได้แก่ (1) ชั้นเครือข่ายและ AWS: Security Group, Private Subnet และ LabRole (2) ชั้นฐานข้อมูล: Role ของ Redshift ที่ให้สิทธิ์น้อยที่สุดตามหน้าที่ (ภาคผนวก ง) และ (3) ชั้นแอปพลิเคชัน: Cognito Group เป็นบทบาท และ `middleware.ts` ตรวจสิทธิ์ทุกหน้าและทุก API ตามตาราง `lib/roles.ts`

### 5.1 การกำหนดสิทธิ์ตามบทบาท (Role-Based Access Control)

**ตารางที่ 34** สิทธิ์ระดับฐานข้อมูลและบริการ

| บทบาท / บัญชี | ขอบเขตสิทธิ์ | ข้อมูลส่วนบุคคล | การตรวจสอบ |
| --- | --- | --- | --- |
| Pipeline Service<br>`etl_loader` (olytics_etl, Glue/Lambda ผ่าน LabRole) | SELECT/INSERT/UPDATE/DELETE บน ops, stg, dw; EXECUTE sp_load_batch, sp_publish | รับเฉพาะข้อมูลที่ Pseudonymize แล้ว | ops.load_batch, CloudWatch, CloudTrail |
| Dashboard / API Reader<br>`dashboard_reader` (olytics_web, olytics_api_ro) | SELECT เฉพาะ 15 KPI View | ไม่เห็นระดับรายบุคคล (ข้อมูลรวม) | Redshift STL_QUERY / SYS_QUERY_HISTORY |
| Analyst<br>`analyst_reader` | KPI View, vw_sale_items, vw_orders, vw_latest_review, v_user_analytics และมิติที่ไม่ใช่ลูกค้า | เห็นรหัสแฝง (pseudo id) และรหัสไปรษณีย์ที่ปิดบัง ไม่เห็น customer_id | Query Log; ทบทวนสิทธิ์รายภาคเรียน |
| Admin<br>(Migration Owner / ผู้ดูแลคลังข้อมูล) | สร้าง Schema, Procedure, Role และบัญชี; ไม่ใช้บัญชีนี้กับเว็บ | เข้าถึงได้ทั้งหมดเฉพาะงานดูแล | CloudTrail; บันทึกเหตุผลการใช้ |
| Auditor<br>`ops_auditor` | SELECT ops.load_batch, reject_record, publish_state | ไม่มี | สิทธิ์ชั่วคราวมีวันหมดอายุ |
| Branch / Regional Manager<br>`seller_scoped_reader` [ระยะที่ 2] | SELECT v_br05, v_br06 เฉพาะรัฐที่กำหนดใน ops.state_access ผ่าน Redshift RLS | ไม่มี | ทดสอบการปฏิเสธข้ามรัฐ (AT09) |

**ตารางที่ 35** สิทธิ์ระดับแอปพลิเคชัน olytics-web (lib/roles.ts)

| บทบาท (Cognito Group) | หน้าที่เห็น | หน้าหลังเข้าสู่ระบบ | BR |
| --- | --- | --- | --- |
| executive | Overview | /overview | BR01 BR02 |
| finance | Overview, Payments | /payments | BR03 |
| category | Overview, Categories | /categories | BR04 BR14 |
| seller | Overview, Sellers | /sellers | BR05 BR06 BR07 |
| logistics | Overview, Delivery | /delivery | BR08 BR09 |
| cx | Overview, Customers & Reviews | /customers | BR10 BR11 BR12 |
| marketing | Overview, Marketing | /marketing | BR13 BR14 |
| analyst | ทุก Dashboard + Query Lab | /overview | ทั้งหมด + UC-03 |
| admin | ทุก Dashboard + Query Lab + Settings | /overview | ทั้งหมด |

ผู้ใช้ที่อยู่หลาย Group ได้สิทธิ์ของบทบาทที่สูงที่สุดตามลำดับ admin > analyst > executive > finance > category > seller > logistics > cx > marketing ผู้ใช้ที่ไม่อยู่ใน Group ใดจะเข้าสู่ระบบไม่ได้และได้รับข้อความให้ติดต่อผู้ดูแล การเปิด URL ที่ไม่มีสิทธิ์จะถูกพากลับหน้าหลักของบทบาท และ API ตอบ 403

### 5.2 นโยบายความปลอดภัยและการคุ้มครองข้อมูลส่วนบุคคล (PDPA & Data Protection Policy)

**ตารางที่ 36** นโยบายข้อมูลและการคุ้มครองข้อมูลส่วนบุคคล

| รายการ | การควบคุม | เกณฑ์ตรวจสอบ |
| --- | --- | --- |
| การจัดชั้นข้อมูล | customer_unique_id, customer_id และรหัสไปรษณีย์ = ข้อมูลจำกัดสิทธิ์; ยอดรวมและ KPI = ข้อมูลภายใน; ข้อความรีวิว = ไม่นำเข้า (Data Minimization) | ทบทวนเมื่อเพิ่มแหล่งข้อมูลใหม่ เช่น Web Events |
| Pseudonymization | HMAC-SHA256 ด้วยกุญแจลับใน AWS Secrets Manager (`HMAC_SECRET_ID`) แยกจากข้อมูล ตัด 32 hex ให้พอดี VARCHAR(32); ค่าเดิมไม่ถูกเก็บในคลังข้อมูล | ทดสอบรูปแบบ 32 hex ทุกแถว; หมุนกุญแจต้อง Reload ประวัติทั้งหมด; ไม่อ้างว่าระบุตัวบุคคลกลับไม่ได้ |
| Data Masking บน View | `dw.v_user_analytics` แสดง pseudo id, รัฐ/เมืองล่าสุด, รหัสไปรษณีย์ 2 หลัก + `xxx` และสรุปการซื้อ; ไม่เปิด customer_id; ทางเลือกบน Redshift: Dynamic Data Masking Policy | Role analyst_reader ไม่มีสิทธิ์อ่าน dim_customer โดยตรง |
| Consent | ชุดข้อมูล Olist ไม่มีข้อมูลความยินยอม (ผู้เผยแพร่ปกปิดตัวตนแล้ว); ระยะที่ 2 ส่ง Web Events เฉพาะเมื่อ consent_analytics = TRUE จาก Consent Management Platform | ไม่มีเหตุการณ์จากผู้ไม่ยินยอมใน Raw Zone |
| Retention | S3 Raw 90 วัน, ops.reject_record 90 วัน, Log ของ Pipeline 1 ปี, Fact และ Curated 5 ปี, Redshift Snapshot ตามนโยบายสำรองข้อมูล | S3 Lifecycle Rule และงานลบรายไตรมาส; ทบทวนปีละครั้ง |
| การเข้ารหัส | S3 SSE-S3; Redshift Encryption at rest; SSL ระหว่าง EC2–Redshift; Cognito ผ่าน HTTPS ของ AWS SDK | ตรวจ Configuration จริงก่อน UAT |
| Secrets | `.env.local` บน EC2 ไม่ commit (อยู่ใน .gitignore); ec2-api ดึงรหัสจาก Secrets Manager ตอน runtime; SESSION_SECRET ตั้งค่าเมื่อใช้หลายเครื่อง | สแกน repository หา Secret ก่อน push |
| Application Security | Cookie HttpOnly + SameSite=Lax + ลายเซ็น HMAC; Middleware บังคับสิทธิ์; Query Lab รับเฉพาะ SELECT/WITH คำสั่งเดียว บล็อก DDL/DML คืนไม่เกิน 50 แถว; ตัวกรองใช้ Parameter Binding | AT08; ทดสอบ SQL Injection บนตัวกรองและ Query Lab |
| Auditability | CloudTrail (AWS API), CloudWatch Logs (Glue, Lambda), ops.load_batch (Lineage ต่อรอบ), Redshift Query History | ย้อนจาก KPI ไป batch_id และไฟล์ต้นทางได้ |

**ตารางที่ 37** ข้อสังเกตด้านความปลอดภัยจากการตรวจซอร์สโค้ดและข้อเสนอแนะ

| ข้อสังเกต | ความเสี่ยง | ข้อเสนอแนะ |
| --- | --- | --- |
| เว็บให้บริการผ่าน HTTP พอร์ต 80 (README ระบุ EC2 เปิดแบบ http) ขณะที่ Login ส่งรหัสผ่านไปยังเซิร์ฟเวอร์ | รหัสผ่านและ Session Cookie ถูกดักฟังได้ระหว่างทาง | วาง Application Load Balancer + ACM Certificate หรือ CloudFront หน้า EC2 และตั้ง `COOKIE_SECURE=true` |
| `lib/redshift.ts` ตั้ง `ssl: { rejectUnauthorized: false }` | เข้ารหัสแต่ไม่ยืนยันตัวตนเซิร์ฟเวอร์ (MITM ภายใน VPC) | ใช้ Redshift CA Bundle และ `rejectUnauthorized: true` |
| `.env.example` ตัวอย่าง `REDSHIFT_USER=awsuser` (บัญชีผู้ดูแลคลัสเตอร์) | Query Lab ใช้บัญชีเดียวกับเว็บ หากเป็น superuser การบล็อกคำสั่งด้วย Regex เป็นด่านเดียว | ใช้บัญชี `olytics_web` ที่มีเพียง Role `dashboard_reader` (ภาคผนวก ง) เป็นด่านหลัก |
| โหมด `AUTH_PROVIDER=local` เก็บรหัสผ่านแบบข้อความใน `.env.local` | เหมาะเฉพาะการทดสอบ | Production ใช้ Cognito เท่านั้น และปิดบัญชี local |
| Cognito ทดสอบแบบ Offline (README ระบุยังไม่ทดสอบกับ User Pool จริง) | อาจพบปัญหาค่า App Client หรือ Group ตอนใช้งานจริง | บรรจุในเกณฑ์ AT08 ก่อน Cutover |
| ไม่มี Rate Limit ที่ `/api/login` ในโหมด local | Brute-force รหัสผ่าน | Cognito มี Throttling ในตัว; เพิ่ม AWS WAF Rate-based Rule เมื่อใช้ ALB |

## 6 การนำไปใช้งานและส่วนต่อประสานผู้ใช้

### 6.1 โครงสร้างส่วนหน้าและระบบแสดงผล olytics-web (Frontend Implementation)

olytics-web ใช้ Next.js App Router โดยหน้าแผงควบคุมเป็น Server Component ที่เรียกฟังก์ชันใน `lib/metrics/` โดยตรงฝั่งเซิร์ฟเวอร์ ส่วนกราฟเป็น Client Component (Recharts) ข้อมูลทุกหน้าอ่านจาก KPI View เท่านั้น เว็บจึงต้องการเพียงสิทธิ์ SELECT บน View ค่าตัวแปร `DATA_SOURCE` สลับระหว่าง Redshift จริงและคลังข้อมูลจำลอง PGlite ที่สร้างตารางตาม ER Diagram พร้อม View ชื่อเดียวกัน ทำให้ SQL ชุดเดียวกันรันได้ทั้งสองแบบ

**ตารางที่ 38** โครงสร้างโมดูลของ olytics-web

| ชั้น / ไฟล์ | หน้าที่ | หมายเหตุ |
| --- | --- | --- |
| `middleware.ts` | ตรวจ Session Cookie ทุกคำขอ (ยกเว้น login, api/login, api/health, static) และตรวจสิทธิ์หน้าตามบทบาท | รันบน Node runtime เพื่อใช้กุญแจ Session ร่วมกับ Route Handler |
| `app/login/` | หน้าเข้าสู่ระบบ รองรับการตั้งรหัสผ่านใหม่ครั้งแรกของ Cognito | LoginForm.tsx |
| `app/(dash)/layout.tsx` + `components/Sidebar.tsx` | โครงหน้าและเมนูที่แสดงเฉพาะหน้าที่บทบาทมีสิทธิ์ พร้อมชื่อผู้ใช้และบทบาท | — |
| `app/(dash)/<page>/page.tsx` | 9 หน้า: overview, payments, categories, sellers, delivery, customers, marketing, query-lab, settings | force-dynamic |
| `app/api/*` | data/[page], filters, query, login, login/new-password, logout, health | ตอบ JSON |
| `lib/metrics/*.ts` | SQL และการรวมผลของแต่ละหน้า คำนวณอัตราจากผลรวม (ไม่เฉลี่ยค่าเฉลี่ย) | หนึ่งไฟล์ต่อหน้า |
| `lib/scope.ts` | แปลงตัวกรองเป็น WHERE ตามคอลัมน์ที่ View มีจริง และรายงานตัวกรองที่ใช้ไม่ได้ (`ignored`) | ตรวจคอลัมน์ View ทุก 5 นาที |
| `lib/sql.ts`, `lib/regions.ts` | รายชื่อ View, ตัวช่วย Parameter และการจัดภาคจากรัฐ | — |
| `lib/db.ts`, `lib/redshift.ts`, `lib/mockdb.ts` | query() ไป Redshift (pg Pool) หรือ PGlite | DATA_SOURCE = redshift \| mock |
| `lib/auth.ts`, `lib/login.ts`, `lib/cognito.ts` | Session HMAC, Login แบบ local/Cognito, Group → Role | — |
| `lib/querylab.ts` | ตรวจและรัน SQL ของ Query Lab พร้อม Preset 4 รายการ (BR01, BR04, BR08, BR03) | แทน `{db}` ด้วย schema |
| `components/` | Card, KpiCard, KpiNotice, Charts (Recharts), DataTable, FilterBar, PageHeader, ErrorState, Icons | แสดงคำเตือนสีส้มเมื่อการ์ดยังไม่ขึ้นกับตัวกรอง |

**ตารางที่ 39** หน้าแผงควบคุม ตัวกรอง และแหล่งข้อมูล

| หน้า | เนื้อหาหลัก | ตัวกรอง | View |
| --- | --- | --- | --- |
| Overview | การ์ดยอดขาย คำสั่งซื้อ ชิ้น ลูกค้า อัตราซื้อซ้ำ AOV ราคาเฉลี่ย การเติบโตเดือนล่าสุด; กราฟรายเดือน; Top 5 หมวด; ยอดขายตามรัฐและภาค | ปี เดือน ภาค รัฐ | v_br01, v_br11, v_br13, v_br14 |
| Payments | มูลค่าและจำนวนรายการชำระตามวิธีชำระ สัดส่วน และหมายเหตุกระทบยอดกับยอดขาย | ตามคอลัมน์ View | v_br03, v_br01 |
| Categories | ยอดขาย ชิ้น ราคาเฉลี่ย ตารางหมวด และแนวโน้มรายเดือน | ปี เดือน หมวด | v_br14 |
| Sellers | ผู้ขายที่มียอดขาย อัตราส่งมอบทันเวลา ผู้ขายไม่มียอดขายตามรัฐและภาค ตารางผู้ขาย | ปี เดือน ภาค รัฐผู้ขาย | v_br05, v_br06, v_br07 |
| Delivery | วันจัดส่งเฉลี่ย อัตราส่งช้า แนวโน้มรายเดือน ตามรัฐและภาค | ปี เดือน ภาค รัฐลูกค้า | v_br08, v_br09 |
| Customers & Reviews | คะแนนรีวิวเฉลี่ยและการกระจาย อัตราซื้อซ้ำ อัตราล้มเหลว/ยกเลิก/ไม่มีสินค้า | ปี เดือน | v_br10, v_br11, v_br12 |
| Marketing | ลูกค้าและยอดขายตามรัฐ ภาค และเมืองยอดนิยม ยอดขายรายเดือน Top หมวด | ปี เดือน หมวด ภาค รัฐ | v_br13, v_br14 |
| Query Lab | เขียน SQL อ่านอย่างเดียว เลือก Preset แสดงเวลาประมวลผลและผลลัพธ์ไม่เกิน 50 แถว | — | ทุก KPI View |
| Settings | สถานะเชื่อมต่อคลังข้อมูล ความหน่วง ค่าคอนฟิก และตารางสิทธิ์ของแต่ละบทบาท | — | SELECT 1 |

ระบบไม่ได้เป็นการแสดงผลแบบ Real-time Streaming ข้อมูลเปลี่ยนตามรอบ Batch แต่ทุกหน้าสืบค้น View ใหม่ทุกครั้งที่เปิดหรือเปลี่ยนตัวกรอง จึงแสดงรอบที่เผยแพร่ล่าสุดทันทีหลัง COMMIT (Near Real-time ตามรอบข้อมูล) เมื่อเลือกเดือน การ์ดและตารางกรองตามเดือน ส่วนกราฟแนวโน้มแสดงทั้งปีที่เลือกและมีหมายเหตุกำกับ การ์ดที่ View ยังไม่มีคอลัมน์ของตัวกรองจะแสดงคำเตือนว่ายังไม่ขึ้นกับตัวกรองนั้น และเปิดใช้เองเมื่อทีมข้อมูลเพิ่มคอลัมน์ตาม VIEW_REQUESTS.md

### 6.2 แผงควบคุมและรายงานการวิเคราะห์ (Analytics Dashboard Screenshots)

> **[ ตำแหน่งภาพที่ 5 — ทีมงานแทรกภาพจริงที่นี่ ]**
>
> *ชนิดภาพ:* Screenshot หน้าเว็บเต็มจอ (1920×1080) จาก `/overview` เข้าสู่ระบบด้วยบทบาท executive และ DATA_SOURCE=redshift
>
> - แถบตัวกรองด้านบน: ปี 2018, เดือน (ทั้งหมด), ภาค, รัฐ — ให้เห็นค่าตัวกรองที่เลือก
> - แถวการ์ด KPI: ยอดขาย (Net Revenue ตามนิยาม M01, R$), จำนวนคำสั่งซื้อ (M02), ลูกค้าไม่ซ้ำ (M14), อัตราซื้อซ้ำ (M11), AOV (M04) และการเติบโตเดือนล่าสุด (M17)
> - กราฟแนวโน้มยอดขายและจำนวนคำสั่งซื้อรายเดือน, กราฟแท่ง Top 5 หมวดสินค้า, ยอดขายตามรัฐ/ภาค
> - หมายเหตุ: ตัวชี้วัด Unique Visitors และ Conversion Rate ของเว็บอยู่ในระยะที่ 2 — ภาพระยะที่ 1 ให้ใช้ลูกค้าไม่ซ้ำและอัตราซื้อซ้ำแทน
> - ห้ามใช้ภาพจากโหมด mock (ตัวเลขสุ่ม) ในรายงานฉบับส่งมอบ หากจำเป็นต้องกำกับว่า “ข้อมูลจำลอง”
>
> *แหล่งอ้างอิง:* app/(dash)/overview/page.tsx, lib/metrics/overview.ts; ภาพต้นแบบ web/Screenshot 2026-10-20 001513.png

**ภาพที่ 5** ภาพหน้าจอแผงควบคุมสรุปภาพรวมผู้บริหาร (Executive Overview Dashboard UI)

> **[ ตำแหน่งภาพที่ 6 — ทีมงานแทรกภาพจริงที่นี่ ]**
>
> *ชนิดภาพ:* Screenshot 2 ภาพเรียงกัน (ก) `/delivery` และ (ข) `/customers` และภาพ Mock-up ระยะที่ 2 (ค) Web Traffic
>
> - (ก) Delivery: การ์ดวันจัดส่งเฉลี่ย (M10) อัตราส่งช้า (M09) จำนวนที่ส่งถึง แนวโน้มรายเดือน และตารางตามรัฐ/ภาค เลือกภาค Northeast เพื่อแสดงการกรอง
> - (ข) Customers & Reviews: การกระจายคะแนนรีวิว 1–5 (M08) อัตราซื้อซ้ำ (M11) อัตราคำสั่งซื้อล้มเหลว (M12)
> - (ค) ระยะที่ 2: Funnel Analysis (page_view → add_to_cart → checkout_start → purchase), Top Visited Pages, Device Breakdown และ User Session Journey จาก Fact_Web_Events — กำกับว่า “ต้นแบบระยะที่ 2”
>
> *แหล่งอ้างอิง:* app/(dash)/delivery, app/(dash)/customers; ภาพต้นแบบ web/Screenshot 2026-10-20 001532.png

**ภาพที่ 6** ภาพหน้าจอรายงานวิเคราะห์ลูกค้า การจัดส่ง และพฤติกรรมผู้ใช้ (Customer, Delivery & User Behavior Analytics UI)

> **[ ตำแหน่งภาพที่ 7 — ทีมงานแทรกภาพจริงที่นี่ ]**
>
> *ชนิดภาพ:* Screenshot หน้า `/settings` (บทบาท admin) และภาพหน้าจอ AWS Console ประกอบ
>
> - หน้า Settings: กล่อง Warehouse connection (CONNECTED, Round-trip latency, Redshift host/port/database/schema, Athena database/workgroup) และตาราง Role access ของ 9 บทบาท
> - ภาพประกอบ: Amazon Cognito User Pool → Groups (executive … admin) และสมาชิกของแต่ละ Group
> - ภาพประกอบ: ผลสืบค้น ops.load_batch (สถานะ PUBLISHED/FAILED, จำนวน accepted/rejected/deduplicated) จาก Query Lab หรือ Redshift Query Editor เป็นหลักฐาน Log การประมวลผล Pipeline
> - ระยะที่ 2: หน้าจัดการ Data Privacy Consent และสถิติ Pipeline ในเว็บ (ยังไม่มีในซอร์สโค้ด) — ใส่เป็น Mock-up พร้อมคำกำกับ
>
> *แหล่งอ้างอิง:* app/(dash)/settings/page.tsx, lib/roles.ts, ภาคผนวก ข (ops.load_batch)

**ภาพที่ 7** ภาพหน้าจอการจัดการสิทธิ์และการตั้งค่าระบบ (User Management & Data Governance UI)

## 7 การทดสอบ การรับมอบ และแผนการส่งมอบ

### 7.1 เกณฑ์ตรวจรับระบบ (Acceptance Test Specifications)

**ตารางที่ 40** เกณฑ์ตรวจรับ AT01–AT10

| รหัสและกรณี | Scope ทดสอบ | ผลที่ต้องได้ | สถานะหลักฐาน |
| --- | --- | --- | --- |
| AT01 Initial Load | โหลดชุดข้อมูลแรกพร้อมข้อบกพร่องที่จงใจใส่ | fact_order = คำสั่งซื้อที่ผ่าน; ยอด price และ payment stg = dw; สถานะ PUBLISHED | ผ่านบน PostgreSQL 16 (ชุดทดสอบ 65 รายการ); ต้องทดสอบซ้ำบน Redshift ด้วยข้อมูล Olist จริง |
| AT02 Deduplication / Conflict | แถวซ้ำทั้งแถว และคีย์ซ้ำข้อมูลต่าง | ซ้ำทั้งแถวเหลือ 1; คีย์ขัดแย้งเป็น CONFLICT และคำสั่งซื้อถูกพักทั้งคำสั่ง | ผ่าน (ทดสอบในเครื่อง) |
| AT03 Lookup / SCD | ผู้ขายที่ Master มาถึงภายหลัง; Lookup วันที่ | Inferred Member ถูกเติม Attribute โดย Surrogate Key ไม่เปลี่ยน; ไม่มี date_key = −1 | ผ่าน (ทดสอบในเครื่อง); SCD Type 2 ทดสอบในระยะที่ 2 |
| AT04 Financial Reconciliation และ Recovery | บังคับให้ Lookup วิธีชำระล้มเหลว | Procedure หยุดด้วย Payment mismatch, ROLLBACK, สถานะ FAILED, publish_state ชี้รุ่นเดิม; รันซ้ำหลังแก้ได้ PUBLISHED | ผ่าน (ทดสอบในเครื่อง) |
| AT05 Replay | ส่ง Manifest เดิมที่เผยแพร่แล้ว | ระบบข้ามรอบ จำนวนแถวและยอดรวมไม่เปลี่ยน | ผ่าน (ทดสอบในเครื่อง) |
| AT06 Correction | ชุดแก้ไขเปลี่ยนสถานะเป็น canceled และราคา | คำสั่งซื้อไม่ซ้ำ; ราคาใหม่; ถูกตัดจากยอดขาย v_br01 | ผ่าน (ทดสอบในเครื่อง) |
| AT07 KPI Correctness | 15 KPI View เทียบสูตรใน `lib/mockviews.ts` ของทีมเว็บบนข้อมูลชุดเดียวกัน | คอลัมน์ตรงสัญญาเว็บและแถวตรงกันทุก View (v_br07 ตัดสมาชิก Unknown ตามนโยบาย); v_br01 = Fact | ผ่าน 30 รายการ (ทดสอบในเครื่อง); ec2-api เรียก View จริงบน Redshift ผ่าน 46 รายการ |
| AT08 RBAC และ Authentication | ทุกบทบาทเปิดหน้าที่มี/ไม่มีสิทธิ์และเรียก API; Login ผ่าน Cognito จริง | หน้าไม่มีสิทธิ์ redirect, API 403, ไม่มี Session 401; Group → Role ถูกต้อง | Middleware มีในระบบ; Cognito ทดสอบแบบ Offline แล้ว ต้องทดสอบกับ User Pool จริง |
| AT09 Masking และ Row-Level Security | analyst_reader อ่าน v_user_analytics; seller_scoped_reader อ่านข้ามรัฐ | รหัสไปรษณีย์ถูกปิดบัง ไม่เห็น customer_id; RLS ปฏิเสธรัฐที่ไม่ได้รับสิทธิ์ | Masking ผ่าน (ทดสอบในเครื่อง); RLS เป็นระยะที่ 2 |
| AT10 Query Latency SLA | เปิดหน้า Overview และ Delivery ด้วยตัวกรองปี/เดือน/รัฐ บน Redshift ra3.large ข้อมูลเต็มชุด | เวลาตอบสนองของ `/api/data/{page}` ไม่เกิน 5 วินาทีที่ Percentile 95 และ `/api/health` ตอบ 200 | ยังไม่ทดสอบ — ต้องแนบผลวัดพร้อมขนาดข้อมูลและสเปกคลัสเตอร์ |

**ตารางที่ 41** หลักฐานการทดสอบที่มีอยู่

| ชุดทดสอบ | สภาพแวดล้อม | ผล | แหล่งอ้างอิง |
| --- | --- | --- | --- |
| ec2-api Unit Tests | EC2 จริง (Node test runner) | 20 / 20 ผ่าน | ec2-api/DEPLOYMENT.md, test/api.test.js |
| ec2-api `scripts/test-api.sh` | EC2 + Redshift View จริงทั้ง 15 รายการ | 46 รายการ 0 FAIL | ec2-api/DEPLOYMENT.md |
| การปิดกั้น API ภายนอก | คำขอจากภายนอกไปที่ `/api/health` ของ ec2-api | ได้ 403 ตามที่กำหนด | ec2-api/DEPLOYMENT.md |
| Cognito Sign-in | จำลอง Cognito API และ Token ที่เซ็นด้วยกุญแจทดสอบ | ผ่าน (Offline) | code web/olytics-web/README.md |
| ชุดทดสอบคลังข้อมูลและ ETL (ภาคผนวก ก–ค) | PostgreSQL 16 ในเครื่อง (แปลงไวยากรณ์ Redshift เฉพาะ IDENTITY/DISTKEY/SORTKEY/GETDATE) ข้อมูลจำลองรูปแบบ Olist 5 ชุด | 65 / 65 ผ่าน | เอกสารนี้ — test/run_all.sh (ส่งมอบพร้อมซอร์สโค้ด) |
| Lambda Trigger Unit Tests | Python + boto3 จำลอง | 3 / 3 ผ่าน | เอกสารนี้ — test/test_lambda.py |

### 7.2 สรุปรายการผลส่งมอบ (Deliverables Matrix)

**ตารางที่ 42** รายการผลส่งมอบ

| ผลส่งมอบ | ไฟล์ / ตำแหน่ง | เกณฑ์รับมอบ | ผู้รับรอง / สถานะ |
| --- | --- | --- | --- |
| เอกสารออกแบบ DW-OLYTICS-001 | เอกสารฉบับนี้ | ครบทุกหัวข้อ ภาพจริงแทนตำแหน่งภาพที่ 2, 4–7 | อาจารย์ผู้สอน / ฉบับเสนอพิจารณา |
| Data Model และ Data Dictionary | er diagram/Untitled_1.png, ภาคผนวก ก | คอลัมน์ ชนิด Null คีย์ตรงกับ Catalog บน Redshift | ทีม Data / มีในระบบ + ภาคผนวก |
| Pipeline อัตโนมัติ | S3, Lambda, DataBrew, Glue Job; ภาคผนวก ค | ผ่าน AT01–AT06 | ทีม Data / มีในระบบ + สคริปต์อ้างอิง |
| KPI Views 15 รายการ | Redshift schema dw; ภาคผนวก ข | ผ่าน AT07 | ทีม Data / มีในระบบ |
| เว็บแอปพลิเคชัน olytics-web | code web/olytics-web/ (Next.js), deploy/ec2-setup.sh | ผ่าน AT08 และ AT10 | ทีม Web / มีในระบบ |
| Internal API | ec2-api/ (Express, systemd, Nginx) | 46 รายการ 0 FAIL; ภายนอกได้ 403 | ทีม Web / มีในระบบ |
| สิทธิ์และการปกป้องข้อมูล | ภาคผนวก ง, Cognito Groups, Security Groups | ผ่าน AT08–AT09 | ผู้ดูแลระบบ / ออกแบบในเอกสารนี้ |
| Runbook การโหลด การกู้คืน และ Rollback | ตารางที่ 33, ec2-api/README.md (Rollback) | ทดลอง Restore และ Replay สำเร็จ | ผู้ดูแลระบบ |

### 7.3 แผนการส่งมอบและนำขึ้นใช้งาน

**ตารางที่ 43** แผนติดตั้งและ Cutover

| ระยะ | งานและหลักฐาน | ผู้รับผิดชอบ / เกณฑ์ผ่าน |
| --- | --- | --- |
| 1 เตรียมสภาพแวดล้อม | เปิด Learner Lab, ตรวจ VPC/Subnet/Security Group, สร้าง Secret (Redshift, HMAC), Cognito User Pool + App Client (ALLOW_USER_PASSWORD_AUTH) + 9 Groups | ผู้ดูแลระบบ / เชื่อมต่อได้ด้วยบัญชีที่อนุมัติเท่านั้น |
| 2 ติดตั้งคลังข้อมูล | รัน 001_schema.sql → 002_publish.sql → 003_security.sql; สร้างบัญชี olytics_etl, olytics_web, olytics_api_ro | ทีม Data / Catalog ตรงพจนานุกรมข้อมูล |
| 3 ติดตั้ง Pipeline | Deploy Glue Job + Lambda + S3 Event Notification + SNS Topic | ทีม Data / ชุดทดสอบเริ่มงานอัตโนมัติ |
| 4 โหลดข้อมูลและ UAT | อัปโหลดชุด Olist ตามลำดับเวลา; ทดสอบ AT01–AT10; วัดเวลาตอบสนอง | ทีม Data + ผู้ใช้ทุกบทบาท / ผ่านเกณฑ์ทั้งหมด |
| 5 Cutover เว็บ | ตั้ง `.env.local` บน EC2: DATA_SOURCE=redshift, AUTH_PROVIDER=cognito, REDSHIFT_USER=olytics_web; `bash deploy/ec2-setup.sh`; ตรวจ `/api/health` | ทีม Web / Dashboard แสดงข้อมูลจริง |
| 6 ส่งมอบการปฏิบัติงาน | ส่งซอร์สโค้ด เอกสาร Runbook รายการ Secret (ไม่รวมค่า) และขั้นตอนปิดทรัพยากรเมื่อไม่ใช้งานเพื่อรักษางบ Learner Lab | ผู้ดูแลระบบ + อาจารย์ / ลงนามรับมอบ |

## ภาคผนวก ซอร์สโค้ดอ้างอิง

> **สถานะของซอร์สโค้ดในภาคผนวก**
>
> ซอร์สโค้ดภาคผนวก ก–ง จัดทำในเอกสารนี้ตาม ER Diagram, KPI View และสถาปัตยกรรมของ repository (repository มีเฉพาะเว็บแอปพลิเคชันและ Internal API ไม่มีสคริปต์ Glue/Redshift)
>
> ทดสอบแล้วบน PostgreSQL 16 ด้วยชุดทดสอบ 65 รายการ (ผ่านทั้งหมด) โดยแปลงเฉพาะไวยากรณ์ IDENTITY(1,1), DISTSTYLE/DISTKEY/SORTKEY และ GETDATE() — ไวยากรณ์เฉพาะ Redshift (COPY FROM S3, RLS, Data API) ต้องทดสอบบนคลัสเตอร์จริงก่อนใช้งาน

### ภาคผนวก ก ซอร์สโค้ด DDL สร้างโครงสร้างฐานข้อมูล (001_schema.sql)

สร้าง schema ops, stg, dw ตารางควบคุมรอบโหลด ตาราง Staging 9 ตาราง มิติ 7 ตาราง และ Fact 4 ตารางตาม ER Diagram พร้อมข้อมูลตั้งต้นสมาชิก Unknown และโดเมนคงที่ สคริปต์รันซ้ำได้ (IF NOT EXISTS / WHERE NOT EXISTS)

*ไฟล์:* `001_schema.sql`

```sql
-- =====================================================================
-- 001_schema.sql | Olytics Data Warehouse | Amazon Redshift (ra3.large)
-- เอกสารอ้างอิง DW-OLYTICS-001 ภาคผนวก ก
-- สร้าง Schema: ops (ควบคุมรอบโหลด), stg (พื้นที่พักข้อมูลจาก S3 Curated Zone),
-- dw (Star Schema ตาม ER Diagram ของโครงการ และ KPI Views)
-- หมายเหตุ Redshift: PK/FK/UNIQUE เป็น informational constraint (ไม่บังคับ)
--   ความถูกต้องของคีย์จึงตรวจใน ops.sp_load_batch (ภาคผนวก ข) และกฎ DQ
-- Redshift ไม่มีชนิด TINYINT ตาม ER Diagram จึงใช้ SMALLINT แทน
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;

-- ---------------------------------------------------------------------
-- 1) ตารางควบคุมรอบโหลด (Operational Control)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ops.load_batch (
  batch_id                BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  batch_name              VARCHAR(100)  NOT NULL,   -- ชื่อชุดข้อมูลตาม manifest เช่น 2017-01
  manifest_sha256         CHAR(64)      NOT NULL,   -- SHA-256 ของ manifest.json
  contract_version        VARCHAR(20)   NOT NULL,
  source_prefix           VARCHAR(1024) NOT NULL,   -- s3://<bucket>/raw/batch=<name>/
  business_date_from      DATE          NOT NULL,
  business_date_to        DATE          NOT NULL,
  status                  VARCHAR(20)   NOT NULL,   -- RECEIVED VALIDATED LOADED PUBLISHED FAILED
  raw_row_count           BIGINT        NOT NULL DEFAULT 0,
  accepted_row_count      BIGINT        NOT NULL DEFAULT 0,
  rejected_row_count      BIGINT        NOT NULL DEFAULT 0,
  deduplicated_row_count  BIGINT        NOT NULL DEFAULT 0,
  warning_row_count       BIGINT        NOT NULL DEFAULT 0,
  inferred_member_count   BIGINT        NOT NULL DEFAULT 0,
  source_sales_amount     DECIMAL(18,2),
  target_sales_amount     DECIMAL(18,2),
  source_payment_amount   DECIMAL(18,2),
  target_payment_amount   DECIMAL(18,2),
  started_at              TIMESTAMP     NOT NULL DEFAULT GETDATE(),
  finished_at             TIMESTAMP,
  error_message           VARCHAR(4000),
  PRIMARY KEY (batch_id),
  UNIQUE (batch_name, manifest_sha256)
) DISTSTYLE ALL;

CREATE TABLE IF NOT EXISTS ops.reject_record (
  reject_id          BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  batch_id           BIGINT       NOT NULL,
  entity_type        VARCHAR(30)  NOT NULL,   -- orders order_items payments reviews customers sellers products
  source_row_number  BIGINT       NOT NULL,   -- ลำดับแถวข้อมูลในไฟล์ (ไม่รวม header)
  business_key       VARCHAR(200),
  rule_code          VARCHAR(10)  NOT NULL,   -- DQ01 .. DQ12
  record_status      VARCHAR(20)  NOT NULL,   -- REJECTED CONFLICT WARNING RESOLVED
  error_detail       VARCHAR(1000) NOT NULL,
  resolved_batch_id  BIGINT,
  created_at         TIMESTAMP    NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY (reject_id),
  FOREIGN KEY (batch_id) REFERENCES ops.load_batch(batch_id)
) DISTSTYLE ALL;

CREATE TABLE IF NOT EXISTS ops.publish_state (
  dataset           VARCHAR(50) NOT NULL,     -- olist_sales
  batch_id          BIGINT      NOT NULL,
  business_date_to  DATE        NOT NULL,
  published_at      TIMESTAMP   NOT NULL DEFAULT GETDATE(),
  PRIMARY KEY (dataset),
  FOREIGN KEY (batch_id) REFERENCES ops.load_batch(batch_id)
) DISTSTYLE ALL;

-- ตารางสิทธิ์ระดับรัฐสำหรับบทบาทที่ถูกจำกัดขอบเขต (ใช้กับ RLS ในภาคผนวก ง)
CREATE TABLE IF NOT EXISTS ops.state_access (
  login_name  VARCHAR(128) NOT NULL,
  state       CHAR(2)      NOT NULL,
  PRIMARY KEY (login_name, state)
) DISTSTYLE ALL;

-- ---------------------------------------------------------------------
-- 2) พื้นที่พักข้อมูล (Staging) — โหลดด้วย COPY ... FORMAT AS PARQUET
--    จาก s3://<bucket>/curated/batch_id=<n>/<entity>/ และล้างทุกรอบด้วย DELETE
--    (ไม่ใช้ TRUNCATE เพราะ TRUNCATE ใน Redshift จะ COMMIT ธุรกรรมทันที)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg.customer (
  customer_id         VARCHAR(32) NOT NULL,
  customer_unique_id  VARCHAR(32) NOT NULL,   -- Pseudonymized ด้วย HMAC-SHA256 (32 hex แรก)
  zip_code_prefix     VARCHAR(5),
  city                VARCHAR(100),
  state               CHAR(2)
);

CREATE TABLE IF NOT EXISTS stg.seller (
  seller_id        VARCHAR(32) NOT NULL,
  zip_code_prefix  VARCHAR(5),
  city             VARCHAR(100),
  state            CHAR(2)
);

CREATE TABLE IF NOT EXISTS stg.product (
  product_id        VARCHAR(32) NOT NULL,
  category_name     VARCHAR(100),
  category_english  VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS stg.calendar (
  full_date  DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS stg.order_header (
  order_id       VARCHAR(32) NOT NULL,
  customer_id    VARCHAR(32) NOT NULL,
  order_status   VARCHAR(20) NOT NULL,
  purchase_date  DATE        NOT NULL,
  total_sales    DECIMAL(14,2),
  total_freight  DECIMAL(14,2),
  total_payment  DECIMAL(14,2),
  delivery_days  DECIMAL(10,2),
  late_flag      SMALLINT
);

CREATE TABLE IF NOT EXISTS stg.order_item (
  order_id       VARCHAR(32)   NOT NULL,
  order_item_id  INT           NOT NULL,
  customer_id    VARCHAR(32)   NOT NULL,
  seller_id      VARCHAR(32)   NOT NULL,
  product_id     VARCHAR(32)   NOT NULL,
  order_status   VARCHAR(20)   NOT NULL,
  purchase_date  DATE          NOT NULL,
  price          DECIMAL(12,2) NOT NULL,
  freight_value  DECIMAL(12,2) NOT NULL,
  on_time_flag   SMALLINT
);

CREATE TABLE IF NOT EXISTS stg.payment (
  order_id              VARCHAR(32)   NOT NULL,
  payment_sequential    SMALLINT      NOT NULL,
  customer_id           VARCHAR(32)   NOT NULL,
  purchase_date         DATE          NOT NULL,
  payment_type          VARCHAR(20)   NOT NULL,
  payment_installments  SMALLINT      NOT NULL,
  payment_value         DECIMAL(12,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS stg.review (
  review_id     VARCHAR(32) NOT NULL,
  order_id      VARCHAR(32) NOT NULL,
  customer_id   VARCHAR(32) NOT NULL,
  review_date   DATE        NOT NULL,
  review_score  SMALLINT    NOT NULL
);

-- รายการที่ไม่ผ่าน DQ ของรอบนี้ (คอลัมน์ตรงกับไฟล์ Parquet) ก่อนย้ายเข้า ops.reject_record
CREATE TABLE IF NOT EXISTS stg.reject (
  batch_id           BIGINT        NOT NULL,
  entity_type        VARCHAR(30)   NOT NULL,
  source_row_number  BIGINT        NOT NULL,
  business_key       VARCHAR(200),
  rule_code          VARCHAR(10)   NOT NULL,
  record_status      VARCHAR(20)   NOT NULL,
  error_detail       VARCHAR(1000) NOT NULL
);

-- ---------------------------------------------------------------------
-- 3) ตารางมิติ (Dimension Tables) — ตาม ER Diagram (er diagram/Untitled_1.png)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw.dim_date (
  date_key        INT         NOT NULL,   -- YYYYMMDD
  full_date       DATE        NOT NULL,
  day_of_month    SMALLINT    NOT NULL,
  month_number    SMALLINT    NOT NULL,
  month_name      VARCHAR(15) NOT NULL,
  quarter_number  SMALLINT    NOT NULL,
  year_number     SMALLINT    NOT NULL,
  PRIMARY KEY (date_key),
  UNIQUE (full_date)
) DISTSTYLE ALL SORTKEY (date_key);

CREATE TABLE IF NOT EXISTS dw.dim_customer (
  customer_key        BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  customer_id         VARCHAR(32) NOT NULL,   -- NK: รหัสลูกค้าระดับคำสั่งซื้อของ Olist
  customer_unique_id  VARCHAR(32) NOT NULL,   -- Durable key ของบุคคล (Pseudonymized)
  zip_code_prefix     VARCHAR(5),
  city                VARCHAR(100),
  state               CHAR(2),
  PRIMARY KEY (customer_key),
  UNIQUE (customer_id)
) DISTSTYLE ALL SORTKEY (customer_id);

CREATE TABLE IF NOT EXISTS dw.dim_seller (
  seller_key       BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  seller_id        VARCHAR(32) NOT NULL,
  zip_code_prefix  VARCHAR(5),
  city             VARCHAR(100),
  state            CHAR(2),
  PRIMARY KEY (seller_key),
  UNIQUE (seller_id)
) DISTSTYLE ALL SORTKEY (seller_id);

CREATE TABLE IF NOT EXISTS dw.dim_product (
  product_key       BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  product_id        VARCHAR(32) NOT NULL,
  category_name     VARCHAR(100),
  category_english  VARCHAR(100),
  PRIMARY KEY (product_key),
  UNIQUE (product_id)
) DISTSTYLE ALL SORTKEY (product_id);

CREATE TABLE IF NOT EXISTS dw.dim_order_status (
  order_status_key  SMALLINT    NOT NULL,
  order_status      VARCHAR(20) NOT NULL,
  PRIMARY KEY (order_status_key),
  UNIQUE (order_status)
) DISTSTYLE ALL;

CREATE TABLE IF NOT EXISTS dw.dim_payment_method (
  payment_method_key  SMALLINT    NOT NULL,
  payment_type        VARCHAR(20) NOT NULL,
  PRIMARY KEY (payment_method_key),
  UNIQUE (payment_type)
) DISTSTYLE ALL;

CREATE TABLE IF NOT EXISTS dw.dim_review_score (
  review_score_key  SMALLINT NOT NULL,
  review_score      SMALLINT NOT NULL,
  PRIMARY KEY (review_score_key),
  UNIQUE (review_score)
) DISTSTYLE ALL;

-- ---------------------------------------------------------------------
-- 4) ตารางข้อเท็จจริง (Fact Tables) — DISTKEY(order_id) ให้ 4 Fact
--    อยู่ Slice เดียวกันเมื่อ JOIN ตาม order_id; SORTKEY ตามวันที่
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dw.fact_order (
  order_key          BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  order_id           VARCHAR(32) NOT NULL,
  purchase_date_key  INT         NOT NULL,
  customer_key       BIGINT      NOT NULL,
  order_status_key   SMALLINT    NOT NULL,
  total_sales        DECIMAL(14,2),
  total_freight      DECIMAL(14,2),
  total_payment      DECIMAL(14,2),
  order_count        SMALLINT    NOT NULL,
  delivery_days      DECIMAL(10,2),
  late_flag          SMALLINT,
  load_batch_id      BIGINT      NOT NULL,
  PRIMARY KEY (order_key),
  UNIQUE (order_id),
  FOREIGN KEY (purchase_date_key) REFERENCES dw.dim_date(date_key),
  FOREIGN KEY (customer_key)      REFERENCES dw.dim_customer(customer_key),
  FOREIGN KEY (order_status_key)  REFERENCES dw.dim_order_status(order_status_key)
) DISTKEY (order_id) SORTKEY (purchase_date_key);

CREATE TABLE IF NOT EXISTS dw.fact_order_item (
  order_item_key     BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  order_id           VARCHAR(32)   NOT NULL,
  order_item_id      INT           NOT NULL,
  purchase_date_key  INT           NOT NULL,
  customer_key       BIGINT        NOT NULL,
  seller_key         BIGINT        NOT NULL,
  product_key        BIGINT        NOT NULL,
  order_status_key   SMALLINT      NOT NULL,
  price              DECIMAL(12,2) NOT NULL,
  freight_value      DECIMAL(12,2) NOT NULL,
  item_count         SMALLINT      NOT NULL,
  on_time_flag       SMALLINT,
  load_batch_id      BIGINT        NOT NULL,
  PRIMARY KEY (order_item_key),
  UNIQUE (order_id, order_item_id),
  FOREIGN KEY (purchase_date_key) REFERENCES dw.dim_date(date_key),
  FOREIGN KEY (customer_key)      REFERENCES dw.dim_customer(customer_key),
  FOREIGN KEY (seller_key)        REFERENCES dw.dim_seller(seller_key),
  FOREIGN KEY (product_key)       REFERENCES dw.dim_product(product_key),
  FOREIGN KEY (order_status_key)  REFERENCES dw.dim_order_status(order_status_key)
) DISTKEY (order_id) SORTKEY (purchase_date_key);

CREATE TABLE IF NOT EXISTS dw.fact_payment (
  payment_key           BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  order_id              VARCHAR(32)   NOT NULL,
  purchase_date_key     INT           NOT NULL,
  customer_key          BIGINT        NOT NULL,
  payment_method_key    SMALLINT      NOT NULL,
  payment_sequential    SMALLINT      NOT NULL,
  payment_installments  SMALLINT      NOT NULL,
  payment_value         DECIMAL(12,2) NOT NULL,
  load_batch_id         BIGINT        NOT NULL,
  PRIMARY KEY (payment_key),
  UNIQUE (order_id, payment_sequential),
  FOREIGN KEY (purchase_date_key)  REFERENCES dw.dim_date(date_key),
  FOREIGN KEY (customer_key)       REFERENCES dw.dim_customer(customer_key),
  FOREIGN KEY (payment_method_key) REFERENCES dw.dim_payment_method(payment_method_key)
) DISTKEY (order_id) SORTKEY (purchase_date_key);

CREATE TABLE IF NOT EXISTS dw.fact_review (
  review_key        BIGINT GENERATED BY DEFAULT AS IDENTITY(1,1) NOT NULL,
  review_id         VARCHAR(32) NOT NULL,
  order_id          VARCHAR(32) NOT NULL,
  review_date_key   INT         NOT NULL,
  customer_key      BIGINT      NOT NULL,
  review_score_key  SMALLINT    NOT NULL,
  review_count      SMALLINT    NOT NULL,
  load_batch_id     BIGINT      NOT NULL,
  PRIMARY KEY (review_key),
  UNIQUE (review_id, order_id),
  FOREIGN KEY (review_date_key)  REFERENCES dw.dim_date(date_key),
  FOREIGN KEY (customer_key)     REFERENCES dw.dim_customer(customer_key),
  FOREIGN KEY (review_score_key) REFERENCES dw.dim_review_score(review_score_key)
) DISTKEY (order_id) SORTKEY (review_date_key);

-- ---------------------------------------------------------------------
-- 5) ข้อมูลตั้งต้น (Bootstrap): สมาชิก Unknown (-1) และมิติโดเมนคงที่
-- ---------------------------------------------------------------------
INSERT INTO ops.load_batch (batch_id, batch_name, manifest_sha256, contract_version, source_prefix,
                            business_date_from, business_date_to, status)
SELECT 0, 'BOOTSTRAP', REPEAT('0', 64), '1.0', 'bootstrap', '1900-01-01', '1900-01-01', 'PUBLISHED'
WHERE NOT EXISTS (SELECT 1 FROM ops.load_batch WHERE batch_id = 0);

INSERT INTO dw.dim_date (date_key, full_date, day_of_month, month_number, month_name, quarter_number, year_number)
SELECT -1, '1900-01-01', 1, 1, 'Unknown', 1, 1900
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_date WHERE date_key = -1);

INSERT INTO dw.dim_customer (customer_key, customer_id, customer_unique_id, zip_code_prefix, city, state)
SELECT -1, '__UNKNOWN__', '__UNKNOWN__', NULL, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_customer WHERE customer_key = -1);

INSERT INTO dw.dim_seller (seller_key, seller_id, zip_code_prefix, city, state)
SELECT -1, '__UNKNOWN__', NULL, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_seller WHERE seller_key = -1);

INSERT INTO dw.dim_product (product_key, product_id, category_name, category_english)
SELECT -1, '__UNKNOWN__', NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_product WHERE product_key = -1);

-- โดเมนสถานะคำสั่งซื้อของ Olist (รหัสคงที่ ห้ามเปลี่ยนเลขหลังใช้งาน)
INSERT INTO dw.dim_order_status (order_status_key, order_status)
SELECT k, s FROM (
            SELECT 1 AS k, 'delivered'   AS s
  UNION ALL SELECT 2, 'shipped'
  UNION ALL SELECT 3, 'canceled'
  UNION ALL SELECT 4, 'unavailable'
  UNION ALL SELECT 5, 'invoiced'
  UNION ALL SELECT 6, 'processing'
  UNION ALL SELECT 7, 'created'
  UNION ALL SELECT 8, 'approved'
) v WHERE NOT EXISTS (SELECT 1 FROM dw.dim_order_status d WHERE d.order_status_key = v.k);

INSERT INTO dw.dim_payment_method (payment_method_key, payment_type)
SELECT k, t FROM (
            SELECT 1 AS k, 'credit_card' AS t
  UNION ALL SELECT 2, 'boleto'
  UNION ALL SELECT 3, 'voucher'
  UNION ALL SELECT 4, 'debit_card'
  UNION ALL SELECT 5, 'not_defined'
) v WHERE NOT EXISTS (SELECT 1 FROM dw.dim_payment_method d WHERE d.payment_method_key = v.k);

INSERT INTO dw.dim_review_score (review_score_key, review_score)
SELECT k, k FROM (
            SELECT 1 AS k UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
) v WHERE NOT EXISTS (SELECT 1 FROM dw.dim_review_score d WHERE d.review_score_key = v.k);
```

### ภาคผนวก ข ซอร์สโค้ด Stored Procedures และ Data Publishing (002_publish.sql)

ops.sp_load_batch โหลดมิติ Inferred Member และ Fact แบบ Delete-Insert พร้อมกระทบยอด DQ09–DQ10; ops.sp_publish ตรวจยอด View กับ Fact แล้วบันทึกรุ่นเผยแพร่; และ KPI View 15 รายการที่มีชื่อและคอลัมน์ตรงกับที่ olytics-web และ ec2-api อ่าน

*ไฟล์:* `002_publish.sql`

```sql
-- =====================================================================
-- 002_publish.sql | Olytics Data Warehouse | Amazon Redshift
-- เอกสารอ้างอิง DW-OLYTICS-001 ภาคผนวก ข
-- (1) ops.sp_load_batch  : โหลดมิติและ Fact จาก stg -> dw แบบ idempotent พร้อมกระทบยอด
-- (2) ops.sp_publish     : ยืนยันรุ่นข้อมูลที่เผยแพร่ให้ Dashboard
-- (3) KPI Views dw.v_br01 .. v_br14 (15 views) ที่เว็บ olytics-web และ ec2-api อ่าน
-- ผู้เรียก (warehouse_loader.py) เป็นผู้ควบคุม BEGIN/COMMIT/ROLLBACK
-- =====================================================================

CREATE OR REPLACE PROCEDURE ops.sp_load_batch(p_batch BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
  v_status        VARCHAR(20);
  v_inferred      BIGINT := 0;
  v_n             BIGINT;
  v_src_orders    BIGINT;
  v_tgt_orders    BIGINT;
  v_src_items     BIGINT;
  v_tgt_items     BIGINT;
  v_src_pay_rows  BIGINT;
  v_tgt_pay_rows  BIGINT;
  v_src_reviews   BIGINT;
  v_tgt_reviews   BIGINT;
  v_src_sales     DECIMAL(18,2);
  v_tgt_sales     DECIMAL(18,2);
  v_src_payment   DECIMAL(18,2);
  v_tgt_payment   DECIMAL(18,2);
BEGIN
  SELECT status INTO v_status FROM ops.load_batch WHERE batch_id = p_batch;
  IF v_status IS NULL THEN
    RAISE EXCEPTION 'Batch % not registered', p_batch;
  END IF;
  IF v_status <> 'VALIDATED' THEN
    RAISE EXCEPTION 'Batch % must be VALIDATED before loading (current: %)', p_batch, v_status;
  END IF;

  -- ---------- 1) ปฏิทิน: เพิ่มเฉพาะวันที่ยังไม่มี ----------
  INSERT INTO dw.dim_date (date_key, full_date, day_of_month, month_number, month_name, quarter_number, year_number)
  SELECT DISTINCT
         CAST(TO_CHAR(c.full_date, 'YYYYMMDD') AS INT),
         c.full_date,
         CAST(EXTRACT(DAY   FROM c.full_date) AS SMALLINT),
         CAST(EXTRACT(MONTH FROM c.full_date) AS SMALLINT),
         CASE CAST(EXTRACT(MONTH FROM c.full_date) AS INT)
           WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March'
           WHEN 4 THEN 'April'   WHEN 5 THEN 'May'      WHEN 6 THEN 'June'
           WHEN 7 THEN 'July'    WHEN 8 THEN 'August'   WHEN 9 THEN 'September'
           WHEN 10 THEN 'October' WHEN 11 THEN 'November' ELSE 'December' END,
         CAST(EXTRACT(QUARTER FROM c.full_date) AS SMALLINT),
         CAST(EXTRACT(YEAR    FROM c.full_date) AS SMALLINT)
  FROM stg.calendar c
  WHERE NOT EXISTS (SELECT 1 FROM dw.dim_date d WHERE d.full_date = c.full_date);

  -- ---------- 2) มิติ SCD Type 1: UPDATE ตาม Natural Key แล้ว INSERT รายการใหม่ ----------
  UPDATE dw.dim_customer
     SET customer_unique_id = s.customer_unique_id, zip_code_prefix = s.zip_code_prefix,
         city = s.city, state = s.state
    FROM stg.customer s
   WHERE dw.dim_customer.customer_id = s.customer_id;
  INSERT INTO dw.dim_customer (customer_id, customer_unique_id, zip_code_prefix, city, state)
  SELECT s.customer_id, s.customer_unique_id, s.zip_code_prefix, s.city, s.state
    FROM stg.customer s
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_customer d WHERE d.customer_id = s.customer_id);

  UPDATE dw.dim_seller
     SET zip_code_prefix = s.zip_code_prefix, city = s.city, state = s.state
    FROM stg.seller s
   WHERE dw.dim_seller.seller_id = s.seller_id;
  INSERT INTO dw.dim_seller (seller_id, zip_code_prefix, city, state)
  SELECT s.seller_id, s.zip_code_prefix, s.city, s.state
    FROM stg.seller s
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_seller d WHERE d.seller_id = s.seller_id);

  UPDATE dw.dim_product
     SET category_name = s.category_name, category_english = s.category_english
    FROM stg.product s
   WHERE dw.dim_product.product_id = s.product_id;
  INSERT INTO dw.dim_product (product_id, category_name, category_english)
  SELECT s.product_id, s.category_name, s.category_english
    FROM stg.product s
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_product d WHERE d.product_id = s.product_id);

  -- ---------- 3) Inferred Members: รหัสที่ Fact อ้างถึงแต่ข้อมูลหลักยังมาไม่ถึง ----------
  -- สร้างแถวที่มีเพียง Natural Key; เมื่อข้อมูลหลักมาถึงในรอบถัดไป ขั้นตอนที่ 2 จะเติม Attribute
  -- โดยคง Surrogate Key เดิม จึงไม่ต้องแก้ Fact ย้อนหลัง
  SELECT COUNT(DISTINCT i.seller_id) INTO v_n FROM stg.order_item i
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_seller d WHERE d.seller_id = i.seller_id);
  v_inferred := v_inferred + v_n;
  INSERT INTO dw.dim_seller (seller_id)
  SELECT DISTINCT i.seller_id FROM stg.order_item i
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_seller d WHERE d.seller_id = i.seller_id);

  SELECT COUNT(DISTINCT i.product_id) INTO v_n FROM stg.order_item i
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_product d WHERE d.product_id = i.product_id);
  v_inferred := v_inferred + v_n;
  INSERT INTO dw.dim_product (product_id)
  SELECT DISTINCT i.product_id FROM stg.order_item i
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_product d WHERE d.product_id = i.product_id);

  SELECT COUNT(DISTINCT h.customer_id) INTO v_n FROM stg.order_header h
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_customer d WHERE d.customer_id = h.customer_id);
  v_inferred := v_inferred + v_n;
  INSERT INTO dw.dim_customer (customer_id, customer_unique_id)
  SELECT DISTINCT h.customer_id, h.customer_id FROM stg.order_header h
   WHERE NOT EXISTS (SELECT 1 FROM dw.dim_customer d WHERE d.customer_id = h.customer_id);

  -- ---------- 4) Fact: แทนที่ทั้งคำสั่งซื้อที่อยู่ในรอบนี้ (Delete-Insert ตาม Natural Key) ----------
  DELETE FROM dw.fact_order      USING stg.order_header h WHERE dw.fact_order.order_id      = h.order_id;
  DELETE FROM dw.fact_order_item USING stg.order_header h WHERE dw.fact_order_item.order_id = h.order_id;
  DELETE FROM dw.fact_payment    USING stg.order_header h WHERE dw.fact_payment.order_id    = h.order_id;
  DELETE FROM dw.fact_review     USING stg.review r
   WHERE dw.fact_review.review_id = r.review_id AND dw.fact_review.order_id = r.order_id;

  INSERT INTO dw.fact_order (order_id, purchase_date_key, customer_key, order_status_key, total_sales,
                             total_freight, total_payment, order_count, delivery_days, late_flag, load_batch_id)
  SELECT h.order_id, COALESCE(d.date_key, -1), COALESCE(c.customer_key, -1), os.order_status_key,
         h.total_sales, h.total_freight, h.total_payment, 1, h.delivery_days, h.late_flag, p_batch
    FROM stg.order_header h
    JOIN dw.dim_order_status os ON os.order_status = h.order_status
    LEFT JOIN dw.dim_date d      ON d.full_date    = h.purchase_date
    LEFT JOIN dw.dim_customer c  ON c.customer_id  = h.customer_id;

  INSERT INTO dw.fact_order_item (order_id, order_item_id, purchase_date_key, customer_key, seller_key,
                                  product_key, order_status_key, price, freight_value, item_count,
                                  on_time_flag, load_batch_id)
  SELECT i.order_id, i.order_item_id, COALESCE(d.date_key, -1), COALESCE(c.customer_key, -1),
         COALESCE(se.seller_key, -1), COALESCE(pr.product_key, -1), os.order_status_key,
         i.price, i.freight_value, 1, i.on_time_flag, p_batch
    FROM stg.order_item i
    JOIN dw.dim_order_status os ON os.order_status = i.order_status
    LEFT JOIN dw.dim_date d      ON d.full_date    = i.purchase_date
    LEFT JOIN dw.dim_customer c  ON c.customer_id  = i.customer_id
    LEFT JOIN dw.dim_seller se   ON se.seller_id   = i.seller_id
    LEFT JOIN dw.dim_product pr  ON pr.product_id  = i.product_id;

  INSERT INTO dw.fact_payment (order_id, purchase_date_key, customer_key, payment_method_key,
                               payment_sequential, payment_installments, payment_value, load_batch_id)
  SELECT p.order_id, COALESCE(d.date_key, -1), COALESCE(c.customer_key, -1), pm.payment_method_key,
         p.payment_sequential, p.payment_installments, p.payment_value, p_batch
    FROM stg.payment p
    JOIN dw.dim_payment_method pm ON pm.payment_type = p.payment_type
    LEFT JOIN dw.dim_date d       ON d.full_date     = p.purchase_date
    LEFT JOIN dw.dim_customer c   ON c.customer_id   = p.customer_id;

  INSERT INTO dw.fact_review (review_id, order_id, review_date_key, customer_key, review_score_key,
                              review_count, load_batch_id)
  SELECT r.review_id, r.order_id, COALESCE(d.date_key, -1), COALESCE(c.customer_key, -1),
         rs.review_score_key, 1, p_batch
    FROM stg.review r
    JOIN dw.dim_review_score rs ON rs.review_score = r.review_score
    LEFT JOIN dw.dim_date d     ON d.full_date     = r.review_date
    LEFT JOIN dw.dim_customer c ON c.customer_id   = r.customer_id;

  -- ---------- 5) กระทบยอด (DQ10) ----------
  SELECT COUNT(*) INTO v_src_orders FROM stg.order_header;
  SELECT COUNT(*) INTO v_tgt_orders FROM dw.fact_order f JOIN stg.order_header h ON h.order_id = f.order_id;
  SELECT COUNT(*), COALESCE(SUM(price), 0) INTO v_src_items, v_src_sales FROM stg.order_item;
  SELECT COUNT(*), COALESCE(SUM(f.price), 0) INTO v_tgt_items, v_tgt_sales
    FROM dw.fact_order_item f JOIN stg.order_item i ON i.order_id = f.order_id AND i.order_item_id = f.order_item_id;
  SELECT COUNT(*), COALESCE(SUM(payment_value), 0) INTO v_src_pay_rows, v_src_payment FROM stg.payment;
  SELECT COUNT(*), COALESCE(SUM(f.payment_value), 0) INTO v_tgt_pay_rows, v_tgt_payment
    FROM dw.fact_payment f JOIN stg.payment p ON p.order_id = f.order_id AND p.payment_sequential = f.payment_sequential;
  SELECT COUNT(*) INTO v_src_reviews FROM stg.review;
  SELECT COUNT(*) INTO v_tgt_reviews
    FROM dw.fact_review f JOIN stg.review r ON r.review_id = f.review_id AND r.order_id = f.order_id;

  IF v_src_orders <> v_tgt_orders THEN
    RAISE EXCEPTION 'Order row mismatch: staged %, loaded %', v_src_orders, v_tgt_orders;
  END IF;
  IF v_src_items <> v_tgt_items OR v_src_sales <> v_tgt_sales THEN
    RAISE EXCEPTION 'Order item mismatch: staged % (%), loaded % (%)', v_src_items, v_src_sales, v_tgt_items, v_tgt_sales;
  END IF;
  IF v_src_pay_rows <> v_tgt_pay_rows OR v_src_payment <> v_tgt_payment THEN
    RAISE EXCEPTION 'Payment mismatch: staged % (%), loaded % (%)', v_src_pay_rows, v_src_payment, v_tgt_pay_rows, v_tgt_payment;
  END IF;
  IF v_src_reviews <> v_tgt_reviews THEN
    RAISE EXCEPTION 'Review row mismatch: staged %, loaded %', v_src_reviews, v_tgt_reviews;
  END IF;

  -- ห้ามมีวันที่ที่ Lookup ไม่สำเร็จ (DQ09)
  SELECT COUNT(*) INTO v_n FROM dw.fact_order WHERE load_batch_id = p_batch AND purchase_date_key = -1;
  IF v_n > 0 THEN
    RAISE EXCEPTION 'Date lookup failed for % orders', v_n;
  END IF;

  -- ความไม่ซ้ำของคีย์ธุรกิจ (Redshift ไม่บังคับ UNIQUE จึงตรวจเอง)
  SELECT COUNT(*) INTO v_n FROM (SELECT order_id FROM dw.fact_order GROUP BY order_id HAVING COUNT(*) > 1) x;
  IF v_n > 0 THEN
    RAISE EXCEPTION 'Duplicate order_id in fact_order: %', v_n;
  END IF;
  SELECT COUNT(*) INTO v_n FROM (SELECT order_id, order_item_id FROM dw.fact_order_item
                                  GROUP BY order_id, order_item_id HAVING COUNT(*) > 1) x;
  IF v_n > 0 THEN
    RAISE EXCEPTION 'Duplicate order item key in fact_order_item: %', v_n;
  END IF;

  UPDATE ops.load_batch
     SET status = 'LOADED', inferred_member_count = v_inferred,
         source_sales_amount = v_src_sales, target_sales_amount = v_tgt_sales,
         source_payment_amount = v_src_payment, target_payment_amount = v_tgt_payment
   WHERE batch_id = p_batch;
END;
$$;

CREATE OR REPLACE PROCEDURE ops.sp_publish(p_batch BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
  v_status   VARCHAR(20);
  v_date_to  DATE;
  v_mismatch BIGINT;
BEGIN
  SELECT status, business_date_to INTO v_status, v_date_to FROM ops.load_batch WHERE batch_id = p_batch;
  IF v_status IS NULL OR v_status <> 'LOADED' THEN
    RAISE EXCEPTION 'Batch % must be LOADED before publishing (current: %)', p_batch, v_status;
  END IF;
  -- ยอดขายรวมของ View ต้องตรงกับ Fact (ตรวจว่า View ไม่ทำให้ยอดซ้ำ/หาย)
  SELECT COUNT(*) INTO v_mismatch FROM (
    SELECT (SELECT COALESCE(SUM(total_sales), 0) FROM dw.v_br01_monthly_sales) AS view_total,
           (SELECT COALESCE(SUM(price), 0) FROM dw.vw_sale_items)              AS fact_total
  ) t WHERE view_total <> fact_total;
  IF v_mismatch > 0 THEN
    RAISE EXCEPTION 'KPI view v_br01 does not reconcile with fact_order_item';
  END IF;

  UPDATE ops.load_batch SET status = 'PUBLISHED', finished_at = GETDATE(), error_message = NULL
   WHERE batch_id = p_batch;
  DELETE FROM ops.publish_state WHERE dataset = 'olist_sales';
  INSERT INTO ops.publish_state (dataset, batch_id, business_date_to, published_at)
  VALUES ('olist_sales', p_batch, v_date_to, GETDATE());
END;
$$;

-- =====================================================================
-- KPI Views — ชื่อและคอลัมน์ตรงกับที่ olytics-web (lib/sql.ts) และ ec2-api (catalog.js) อ่าน
-- รูปแบบนี้เป็นรุ่นเป้าหมายตาม VIEW_REQUESTS.md (มีคอลัมน์ปี/เดือน/รัฐครบ); เว็บตรวจคอลัมน์
-- ทุก 5 นาทีและเปิดตัวกรองตามคอลัมน์ที่มีจริงโดยอัตโนมัติ (lib/scope.ts)
-- "ยอดขาย" = SUM(price) ของรายการสินค้าที่สถานะไม่ใช่ canceled / unavailable (M01)
-- =====================================================================

CREATE OR REPLACE VIEW dw.vw_items AS
SELECT i.order_id, i.order_item_id, i.price, i.freight_value, i.on_time_flag, os.order_status,
       d.year_number, d.month_number,
       c.state AS customer_state, c.city AS customer_city, c.customer_unique_id,
       COALESCE(p.category_english, p.category_name) AS category_name,
       se.seller_id, se.state AS seller_state
  FROM dw.fact_order_item i
  JOIN dw.dim_date d          ON i.purchase_date_key = d.date_key
  JOIN dw.dim_customer c      ON i.customer_key      = c.customer_key
  JOIN dw.dim_product p       ON i.product_key       = p.product_key
  JOIN dw.dim_seller se       ON i.seller_key        = se.seller_key
  JOIN dw.dim_order_status os ON i.order_status_key  = os.order_status_key;

CREATE OR REPLACE VIEW dw.vw_sale_items AS
SELECT * FROM dw.vw_items WHERE order_status NOT IN ('canceled', 'unavailable');

-- M08: หนึ่งรีวิวต่อคำสั่งซื้อ (รีวิวล่าสุด) และนับเดือนตามวันที่รีวิว
CREATE OR REPLACE VIEW dw.vw_latest_review AS
SELECT order_id, review_score, year_number, month_number FROM (
  SELECT r.order_id, rs.review_score, d.year_number, d.month_number,
         ROW_NUMBER() OVER (PARTITION BY r.order_id ORDER BY d.full_date DESC, r.review_key DESC) AS rn
    FROM dw.fact_review r
    JOIN dw.dim_review_score rs ON r.review_score_key = rs.review_score_key
    JOIN dw.dim_date d          ON r.review_date_key  = d.date_key
) x WHERE rn = 1;

CREATE OR REPLACE VIEW dw.vw_orders AS
SELECT o.order_id, o.delivery_days, o.late_flag, os.order_status, d.year_number, d.month_number,
       c.state AS customer_state, c.customer_unique_id
  FROM dw.fact_order o
  JOIN dw.dim_date d          ON o.purchase_date_key = d.date_key
  JOIN dw.dim_customer c      ON o.customer_key      = c.customer_key
  JOIN dw.dim_order_status os ON o.order_status_key  = os.order_status_key;

-- BR01 / M01 M02 M17
CREATE OR REPLACE VIEW dw.v_br01_monthly_sales AS
WITH m AS (
  SELECT year_number, month_number, customer_state,
         SUM(price) AS total_sales, COUNT(DISTINCT order_id) AS total_orders
    FROM dw.vw_sale_items GROUP BY year_number, month_number, customer_state
)
SELECT year_number, month_number, customer_state, total_sales, total_orders,
       ROUND(100.0 * (total_sales - LAG(total_sales) OVER (PARTITION BY customer_state ORDER BY year_number, month_number))
             / NULLIF(LAG(total_sales) OVER (PARTITION BY customer_state ORDER BY year_number, month_number), 0), 2) AS mom_growth_pct
  FROM m;

-- BR02
CREATE OR REPLACE VIEW dw.v_br02_top_states AS
SELECT customer_state AS state, SUM(price) AS total_sales, COUNT(*) AS total_order_items,
       COUNT(DISTINCT order_id) AS total_orders
  FROM dw.vw_sale_items GROUP BY customer_state ORDER BY total_sales DESC LIMIT 5;

CREATE OR REPLACE VIEW dw.v_br02_top_categories AS
SELECT category_name, SUM(price) AS total_sales, COUNT(*) AS total_order_items,
       COUNT(DISTINCT order_id) AS total_orders
  FROM dw.vw_sale_items GROUP BY category_name ORDER BY total_sales DESC LIMIT 5;

-- BR03 / M06 (ใช้ CTE ก่อนคำนวณสัดส่วน เพื่อไม่ซ้อน Aggregate ใน Window)
CREATE OR REPLACE VIEW dw.v_br03_payment_distribution AS
WITH p AS (
  SELECT d.year_number, d.month_number, c.state AS customer_state, pm.payment_type,
         COUNT(*) AS payment_records, SUM(fp.payment_value) AS total_payment
    FROM dw.fact_payment fp
    JOIN dw.dim_payment_method pm ON fp.payment_method_key = pm.payment_method_key
    JOIN dw.dim_date d            ON fp.purchase_date_key  = d.date_key
    JOIN dw.dim_customer c        ON fp.customer_key       = c.customer_key
   GROUP BY d.year_number, d.month_number, c.state, pm.payment_type
)
SELECT year_number, month_number, customer_state, payment_type, payment_records, total_payment,
       ROUND(100.0 * total_payment
             / NULLIF(SUM(total_payment) OVER (PARTITION BY year_number, month_number, customer_state), 0), 2) AS payment_percentage
  FROM p;

-- BR04 / M03 M05
CREATE OR REPLACE VIEW dw.v_br04_category_performance AS
SELECT category_name, SUM(price) AS total_sales, COUNT(*) AS total_items,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND(SUM(price) / NULLIF(COUNT(*), 0), 2) AS avg_item_price
  FROM dw.vw_sale_items GROUP BY category_name;

-- BR05: แถวละ (เดือน, ผู้ขาย, คำสั่งซื้อ) ก่อน เพื่อให้รีวิวของคำสั่งซื้อนับครั้งเดียวต่อผู้ขาย
CREATE OR REPLACE VIEW dw.v_br05_seller_performance AS
WITH so AS (
  SELECT year_number, month_number, seller_id, seller_state, order_id,
         SUM(price) AS sales, COUNT(*) AS items
    FROM dw.vw_sale_items GROUP BY year_number, month_number, seller_id, seller_state, order_id
)
SELECT so.year_number, so.month_number, so.seller_id, so.seller_state,
       SUM(so.sales) AS total_sales, SUM(so.items) AS total_items, COUNT(*) AS total_orders,
       ROUND(AVG(CAST(r.review_score AS DECIMAL(6,2))), 2) AS avg_review_score,
       COUNT(r.order_id) AS reviewed_orders
  FROM so LEFT JOIN dw.vw_latest_review r ON r.order_id = so.order_id
 GROUP BY so.year_number, so.month_number, so.seller_id, so.seller_state;

-- BR06 / M07: ตรงเวลาเมื่อทุกรายการที่มีวันส่งมอบขนส่งส่งทันกำหนด
CREATE OR REPLACE VIEW dw.v_br06_seller_on_time AS
WITH os AS (
  SELECT year_number, month_number, seller_id, seller_state, order_id,
         MIN(on_time_flag) AS f, COUNT(on_time_flag) AS n
    FROM dw.vw_items GROUP BY year_number, month_number, seller_id, seller_state, order_id
)
SELECT year_number, month_number, seller_id, seller_state, COUNT(*) AS total_seller_orders,
       SUM(CASE WHEN n > 0 AND f = 1 THEN 1 ELSE 0 END) AS on_time_orders,
       SUM(CASE WHEN n > 0 AND f = 0 THEN 1 ELSE 0 END) AS late_orders,
       SUM(CASE WHEN n = 0 THEN 1 ELSE 0 END) AS unknown_orders,
       ROUND(100.0 * SUM(CASE WHEN n > 0 AND f = 1 THEN 1 ELSE 0 END)
             / NULLIF(SUM(CASE WHEN n > 0 THEN 1 ELSE 0 END), 0), 2) AS on_time_rate_pct
  FROM os GROUP BY year_number, month_number, seller_id, seller_state;

-- BR07 / M13: แถวรายปีต่อรัฐ และแถวรวมทุกปี (year_number IS NULL)
CREATE OR REPLACE VIEW dw.v_br07_sellers_without_revenue AS
WITH yrs AS (SELECT DISTINCT year_number FROM dw.vw_sale_items),
sold_year AS (SELECT DISTINCT seller_id, year_number FROM dw.vw_sale_items),
sold_all  AS (SELECT DISTINCT seller_id FROM dw.vw_sale_items),
per_year AS (
  SELECT se.state AS seller_state, y.year_number, COUNT(*) AS total_sellers,
         SUM(CASE WHEN s.seller_id IS NULL THEN 1 ELSE 0 END) AS sellers_without_revenue
    FROM dw.dim_seller se CROSS JOIN yrs y
    LEFT JOIN sold_year s ON s.seller_id = se.seller_id AND s.year_number = y.year_number
   WHERE se.seller_key <> -1
   GROUP BY se.state, y.year_number
),
all_time AS (
  SELECT se.state AS seller_state, CAST(NULL AS SMALLINT) AS year_number, COUNT(*) AS total_sellers,
         SUM(CASE WHEN s.seller_id IS NULL THEN 1 ELSE 0 END) AS sellers_without_revenue
    FROM dw.dim_seller se LEFT JOIN sold_all s ON s.seller_id = se.seller_id
   WHERE se.seller_key <> -1
   GROUP BY se.state
)
SELECT seller_state, year_number, total_sellers, sellers_without_revenue,
       total_sellers - sellers_without_revenue AS sellers_with_revenue,
       ROUND(100.0 * sellers_without_revenue / NULLIF(total_sellers, 0), 2) AS no_revenue_rate_pct
  FROM (SELECT * FROM per_year UNION ALL SELECT * FROM all_time) x;

-- BR08 / M09
CREATE OR REPLACE VIEW dw.v_br08_late_delivery AS
SELECT year_number, month_number, customer_state, COUNT(*) AS total_delivered_orders,
       SUM(CASE WHEN late_flag = 1 THEN 1 ELSE 0 END) AS late_orders,
       SUM(CASE WHEN late_flag = 0 THEN 1 ELSE 0 END) AS on_time_orders,
       ROUND(100.0 * SUM(CASE WHEN late_flag = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS late_delivery_rate_pct
  FROM dw.vw_orders WHERE delivery_days IS NOT NULL
 GROUP BY year_number, month_number, customer_state;

-- BR09 / M10
CREATE OR REPLACE VIEW dw.v_br09_delivery_days AS
SELECT year_number, month_number, customer_state, COUNT(*) AS total_delivered_orders,
       ROUND(AVG(delivery_days), 2) AS avg_delivery_days, MIN(delivery_days) AS min_delivery_days,
       MAX(delivery_days) AS max_delivery_days, SUM(delivery_days) AS sum_delivery_days
  FROM dw.vw_orders WHERE delivery_days IS NOT NULL
 GROUP BY year_number, month_number, customer_state;

-- BR10 / M08
CREATE OR REPLACE VIEW dw.v_br10_review_satisfaction AS
WITH g AS (
  SELECT r.year_number, r.month_number, o.customer_state, r.review_score, COUNT(*) AS review_count
    FROM dw.vw_latest_review r JOIN dw.vw_orders o ON o.order_id = r.order_id
   GROUP BY r.year_number, r.month_number, o.customer_state, r.review_score
)
SELECT year_number, month_number, customer_state, review_score, review_count,
       SUM(review_count) OVER (PARTITION BY year_number, month_number, customer_state) AS monthly_total_reviews,
       ROUND(SUM(review_score * review_count) OVER (PARTITION BY year_number, month_number, customer_state) * 1.0
             / NULLIF(SUM(review_count) OVER (PARTITION BY year_number, month_number, customer_state), 0), 2) AS monthly_avg_review_score
  FROM g;

-- BR11 / M11: ลูกค้าซื้อซ้ำ = มีคำสั่งซื้อที่นับยอด >= 2 ภายในกลุ่ม; แถวรวมเมื่อปี/รัฐเป็น NULL
CREATE OR REPLACE VIEW dw.v_br11_repeat_customers AS
WITH base AS (
  SELECT customer_unique_id, year_number, customer_state, order_id
    FROM dw.vw_orders WHERE order_status NOT IN ('canceled', 'unavailable')
),
a AS (SELECT customer_unique_id, COUNT(DISTINCT order_id) AS n FROM base GROUP BY customer_unique_id),
y AS (SELECT customer_unique_id, year_number, COUNT(DISTINCT order_id) AS n FROM base GROUP BY customer_unique_id, year_number),
s AS (SELECT customer_unique_id, customer_state, COUNT(DISTINCT order_id) AS n FROM base GROUP BY customer_unique_id, customer_state),
ys AS (SELECT customer_unique_id, year_number, customer_state, COUNT(DISTINCT order_id) AS n
         FROM base GROUP BY customer_unique_id, year_number, customer_state)
SELECT CAST(NULL AS SMALLINT) AS year_number, CAST(NULL AS CHAR(2)) AS customer_state, COUNT(*) AS total_customers,
       SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END) AS repeat_customers, SUM(CASE WHEN n = 1 THEN 1 ELSE 0 END) AS one_time_customers,
       ROUND(100.0 * SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS repeat_customer_rate_pct
  FROM a
UNION ALL
SELECT year_number, CAST(NULL AS CHAR(2)), COUNT(*), SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END), SUM(CASE WHEN n = 1 THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2)
  FROM y GROUP BY year_number
UNION ALL
SELECT CAST(NULL AS SMALLINT), customer_state, COUNT(*), SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END), SUM(CASE WHEN n = 1 THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2)
  FROM s GROUP BY customer_state
UNION ALL
SELECT year_number, customer_state, COUNT(*), SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END), SUM(CASE WHEN n = 1 THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN n >= 2 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2)
  FROM ys GROUP BY year_number, customer_state;

-- BR12 / M12
CREATE OR REPLACE VIEW dw.v_br12_order_failure_rate AS
SELECT year_number, month_number, customer_state, COUNT(*) AS total_orders,
       SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
       SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) AS unavailable_orders,
       SUM(CASE WHEN order_status IN ('canceled', 'unavailable') THEN 1 ELSE 0 END) AS failed_orders,
       ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS cancellation_rate_pct,
       ROUND(100.0 * SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS unavailable_rate_pct,
       ROUND(100.0 * SUM(CASE WHEN order_status IN ('canceled', 'unavailable') THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS failure_rate_pct
  FROM dw.vw_orders GROUP BY year_number, month_number, customer_state;

-- BR13 / M14 M04
CREATE OR REPLACE VIEW dw.v_br13_customer_geography AS
SELECT year_number, month_number, customer_state, customer_city,
       COUNT(DISTINCT customer_unique_id) AS total_customers, COUNT(DISTINCT order_id) AS total_orders,
       SUM(price) AS total_sales, ROUND(SUM(price) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_value
  FROM dw.vw_sale_items GROUP BY year_number, month_number, customer_state, customer_city;

-- BR14 / M15
CREATE OR REPLACE VIEW dw.v_br14_monthly_category_sales AS
SELECT year_number, month_number, category_name, customer_state, SUM(price) AS total_sales,
       COUNT(*) AS total_items, COUNT(DISTINCT order_id) AS total_orders
  FROM dw.vw_sale_items GROUP BY year_number, month_number, category_name, customer_state;
```

### ภาคผนวก ค ซอร์สโค้ดโปรแกรมโหลดและแปลงข้อมูล Python (warehouse_loader.py)

ส่วนที่ 1 warehouse_loader.py: ตรวจ Manifest (DQ01–DQ02) แปลงข้อมูลและตรวจคุณภาพด้วยฟังก์ชันบริสุทธิ์บน pandas (DQ03–DQ08, Pseudonymization) แล้วส่ง SQL ทั้งชุดเป็นธุรกรรมเดียวผ่าน Redshift Data API รองรับการรันในเครื่องกับ PostgreSQL เพื่อทดสอบ

*ไฟล์:* `warehouse_loader.py`

```python
"""warehouse_loader.py — Olytics ETL: S3 Raw Zone -> S3 Curated Zone -> Amazon Redshift.

เอกสารอ้างอิง DW-OLYTICS-001 ภาคผนวก ค

รูปแบบการรัน
  * AWS Glue Python Shell Job (เรียกโดย lambda_trigger.py เมื่อ manifest.json มาถึง S3 Raw Zone)
      --RAW_PREFIX s3://<bucket>/raw/batch=2017-01/  --CURATED_PREFIX s3://<bucket>/curated/
      --REDSHIFT_SECRET_ARN ...  --REDSHIFT_CLUSTER_ID ...  --REDSHIFT_DATABASE dev
      --COPY_IAM_ROLE arn:aws:iam::<acct>:role/LabRole  --HMAC_SECRET_ID olytics/hmac  [--SNS_TOPIC_ARN ...]
  * ทดสอบในเครื่อง (PostgreSQL ผ่าน psql):  python warehouse_loader.py --local <batch_dir> --psql-dsn <dsn>

หลักการ
  1. ตรวจ Manifest, SHA-256 และจำนวนแถว (DQ01) และคอลัมน์บังคับ (DQ02) ก่อนแตะคลังข้อมูล
  2. แปลงข้อมูลด้วยฟังก์ชันบริสุทธิ์ (pure function) บน pandas: DQ03-DQ08 และสร้างตาราง Staging
  3. ส่ง SQL ทั้งชุดเป็นธุรกรรมเดียว: stg -> ops.sp_load_batch -> ops.sp_publish
     ผิดพลาดที่ขั้นใด ทั้งธุรกรรม ROLLBACK และ Dashboard ยังอ่านรุ่นที่เผยแพร่ก่อนหน้า
  4. Manifest เดิมที่ PUBLISHED แล้วจะไม่ถูกโหลดซ้ำ (Idempotent Replay, DQ11)
"""
from __future__ import annotations

import argparse
import hashlib
import hmac
import io
import json
import numbers
import os
import re
import subprocess
import time
from dataclasses import dataclass, field
from decimal import Decimal, ROUND_HALF_UP

import pandas as pd

CONTRACT_VERSION = "1.0"
TS_FORMAT = "%Y-%m-%d %H:%M:%S"

# Data Contract: ไฟล์ CSV ของชุดข้อมูล Olist และคอลัมน์บังคับ (DQ02)
ENTITIES: dict[str, dict] = {
    "orders": {"required": ["order_id", "customer_id", "order_status", "order_purchase_timestamp",
                            "order_delivered_carrier_date", "order_delivered_customer_date",
                            "order_estimated_delivery_date"], "key": ["order_id"]},
    "order_items": {"required": ["order_id", "order_item_id", "product_id", "seller_id",
                                 "shipping_limit_date", "price", "freight_value"],
                    "key": ["order_id", "order_item_id"]},
    "payments": {"required": ["order_id", "payment_sequential", "payment_type",
                              "payment_installments", "payment_value"],
                 "key": ["order_id", "payment_sequential"]},
    "reviews": {"required": ["review_id", "order_id", "review_score", "review_creation_date"],
                "key": ["review_id", "order_id"]},
    "customers": {"required": ["customer_id", "customer_unique_id", "customer_zip_code_prefix",
                               "customer_city", "customer_state"], "key": ["customer_id"]},
    "sellers": {"required": ["seller_id", "seller_zip_code_prefix", "seller_city", "seller_state"],
                "key": ["seller_id"]},
    "products": {"required": ["product_id", "product_category_name"], "key": ["product_id"]},
    "category_translation": {"required": ["product_category_name", "product_category_name_english"],
                             "key": ["product_category_name"], "optional": True},
}
ORDER_STATUSES = {"delivered", "shipped", "canceled", "unavailable", "invoiced", "processing",
                  "created", "approved"}
PAYMENT_TYPES = {"credit_card", "boleto", "voucher", "debit_card", "not_defined"}
STATE_RE = re.compile(r"^[A-Z]{2}$")

# คอลัมน์ของตาราง Staging ตามลำดับใน 001_schema.sql (COPY FORMAT AS PARQUET อ้างตามลำดับ)
STAGE_COLUMNS: dict[str, list[str]] = {
    "customer": ["customer_id", "customer_unique_id", "zip_code_prefix", "city", "state"],
    "seller": ["seller_id", "zip_code_prefix", "city", "state"],
    "product": ["product_id", "category_name", "category_english"],
    "calendar": ["full_date"],
    "order_header": ["order_id", "customer_id", "order_status", "purchase_date", "total_sales",
                     "total_freight", "total_payment", "delivery_days", "late_flag"],
    "order_item": ["order_id", "order_item_id", "customer_id", "seller_id", "product_id", "order_status",
                   "purchase_date", "price", "freight_value", "on_time_flag"],
    "payment": ["order_id", "payment_sequential", "customer_id", "purchase_date", "payment_type",
                "payment_installments", "payment_value"],
    "review": ["review_id", "order_id", "customer_id", "review_date", "review_score"],
    "reject": ["batch_id", "entity_type", "source_row_number", "business_key", "rule_code",
               "record_status", "error_detail"],
}
# ชนิดข้อมูลสำหรับเขียน Parquet ให้ตรงกับ Redshift (awswrangler dtype)
PARQUET_TYPES = {
    "purchase_date": "date", "review_date": "date", "full_date": "date",
    "total_sales": "decimal(14,2)", "total_freight": "decimal(14,2)", "total_payment": "decimal(14,2)",
    "delivery_days": "decimal(10,2)", "price": "decimal(12,2)", "freight_value": "decimal(12,2)",
    "payment_value": "decimal(12,2)", "late_flag": "smallint", "on_time_flag": "smallint",
    "order_item_id": "int", "payment_sequential": "smallint", "payment_installments": "smallint",
    "review_score": "smallint", "batch_id": "bigint", "source_row_number": "bigint",
}


class BatchError(Exception):
    """ข้อผิดพลาดระดับรอบโหลด: หยุดก่อนเปลี่ยนแปลงคลังข้อมูล"""


@dataclass
class Reject:
    entity: str
    row: int
    key: str
    rule: str
    status: str  # REJECTED CONFLICT WARNING
    detail: str


@dataclass
class TransformResult:
    stage: dict[str, pd.DataFrame]
    rejects: list[Reject] = field(default_factory=list)
    raw_rows: int = 0
    accepted_rows: int = 0
    deduplicated_rows: int = 0

    @property
    def rejected_rows(self) -> int:
        return len({(r.entity, r.row) for r in self.rejects if r.status in ("REJECTED", "CONFLICT")})

    @property
    def warning_rows(self) -> int:
        return len({(r.entity, r.row) for r in self.rejects if r.status == "WARNING"})


# ---------------------------------------------------------------------------
# พื้นที่จัดเก็บต้นทาง: S3 (Production) หรือโฟลเดอร์ในเครื่อง (ทดสอบ)
# ---------------------------------------------------------------------------
class LocalStore:
    def __init__(self, root: str):
        self.root = root

    def read(self, name: str) -> bytes:
        with open(os.path.join(self.root, name), "rb") as fh:
            return fh.read()


class S3Store:
    def __init__(self, prefix: str):
        import boto3
        m = re.match(r"^s3://([^/]+)/(.*)$", prefix.rstrip("/") + "/")
        if not m:
            raise BatchError("RAW_PREFIX must be s3://bucket/path/")
        self.bucket, self.key = m.group(1), m.group(2)
        self.s3 = boto3.client("s3")

    def read(self, name: str) -> bytes:
        return self.s3.get_object(Bucket=self.bucket, Key=self.key + name)["Body"].read()


# ---------------------------------------------------------------------------
# DQ01-DQ02: Manifest, Checksum, จำนวนแถว และ Schema
# ---------------------------------------------------------------------------
def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_manifest(store) -> tuple[dict, str]:
    manifest_bytes = store.read("manifest.json")
    try:
        manifest = json.loads(manifest_bytes)
    except json.JSONDecodeError as e:
        raise BatchError(f"DQ01 manifest is not valid JSON: {e}") from e
    for k in ("batch_name", "contract_version", "date_from", "date_to", "files"):
        if k not in manifest:
            raise BatchError(f"DQ01 manifest missing '{k}'")
    return manifest, sha256_hex(manifest_bytes)


def read_frames(store, manifest: dict) -> dict[str, pd.DataFrame]:
    if manifest["contract_version"] != CONTRACT_VERSION:
        raise BatchError(f"DQ01 unsupported contract_version {manifest['contract_version']}")
    if manifest["date_from"] > manifest["date_to"]:
        raise BatchError("DQ01 date_from is after date_to")
    frames: dict[str, pd.DataFrame] = {}
    for entity, spec in ENTITIES.items():
        meta = manifest["files"].get(entity)
        if meta is None:
            if spec.get("optional"):
                continue
            raise BatchError(f"DQ01 manifest has no file for '{entity}'")
        if "/" in meta["file"] or meta["file"].startswith("."):
            raise BatchError(f"DQ01 file name must be inside the batch folder: {meta['file']}")
        blob = store.read(meta["file"])
        if sha256_hex(blob) != meta["sha256"]:
            raise BatchError(f"DQ01 checksum mismatch for {meta['file']}")
        df = pd.read_csv(io.BytesIO(blob), dtype=str, keep_default_na=True, encoding="utf-8")
        if len(df) != int(meta["row_count"]):
            raise BatchError(f"DQ01 row count mismatch for {meta['file']}: {len(df)} != {meta['row_count']}")
        missing = [c for c in spec["required"] if c not in df.columns]
        if missing:
            raise BatchError(f"DQ02 {entity} is missing columns {missing}")
        df = df.astype(object).where(df.notna(), None)
        df = df.apply(lambda col: col.map(lambda v: v.strip() if isinstance(v, str) else v))
        df = df.where(df != "", None)
        df.insert(0, "_row", range(1, len(df) + 1))  # ลำดับแถวข้อมูล ไม่รวม header
        frames[entity] = df
    return frames


# ---------------------------------------------------------------------------
# ตัวช่วยแปลงข้อมูล
# ---------------------------------------------------------------------------
def money(value) -> Decimal | None:
    if value is None or (isinstance(value, float) and pd.isna(value)) or value == "":
        return None
    return Decimal(str(value)).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def pseudonymize(value: str, key: bytes) -> str:
    """HMAC-SHA256 แบบกำหนดผลได้ซ้ำ (deterministic) ตัดเหลือ 32 hex ให้พอดี VARCHAR(32) ตาม ERD"""
    return hmac.new(key, value.encode("utf-8"), hashlib.sha256).hexdigest()[:32]


def _key(row, cols) -> str:
    return "|".join(str(row[c]) for c in cols)


def dedupe(entity: str, df: pd.DataFrame, rejects: list[Reject]) -> tuple[pd.DataFrame, int]:
    """DQ04: ซ้ำทั้งแถวเก็บแถวแรก; คีย์เดียวกันแต่ข้อมูลต่างกันพักเป็น CONFLICT ทั้งกลุ่ม"""
    keys = ENTITIES[entity]["key"]
    payload = [c for c in df.columns if c != "_row"]
    blank = df[keys].isna().any(axis=1)
    for _, r in df[blank].iterrows():
        rejects.append(Reject(entity, int(r["_row"]), _key(r, keys), "DQ04", "REJECTED", "business key is empty"))
    df = df[~blank]
    exact = df.duplicated(subset=payload, keep="first")
    dropped = int(exact.sum())
    df = df[~exact]
    clash = df.duplicated(subset=keys, keep=False)
    for _, r in df[clash].iterrows():
        rejects.append(Reject(entity, int(r["_row"]), _key(r, keys), "DQ04", "CONFLICT",
                              "same business key with different payload"))
    return df[~clash].copy(), dropped


def reject_rows(entity: str, df: pd.DataFrame, mask: pd.Series, rule: str, detail: str,
                rejects: list[Reject], status: str = "REJECTED") -> pd.DataFrame:
    keys = ENTITIES[entity]["key"]
    for _, r in df[mask].iterrows():
        rejects.append(Reject(entity, int(r["_row"]), _key(r, keys), rule, status, detail))
    return df if status == "WARNING" else df[~mask].copy()


def parse_ts(s: pd.Series) -> pd.Series:
    return pd.to_datetime(s, format=TS_FORMAT, errors="coerce")


# ---------------------------------------------------------------------------
# DQ03-DQ08 และการสร้างตาราง Staging (pure function — ไม่มีการเชื่อมต่อภายนอก)
# ---------------------------------------------------------------------------
def transform(manifest: dict, frames: dict[str, pd.DataFrame], hmac_key: bytes | None) -> TransformResult:
    rejects: list[Reject] = []
    raw_rows = sum(len(df) for df in frames.values())
    dedup_total = 0
    clean: dict[str, pd.DataFrame] = {}
    for entity, df in frames.items():
        clean[entity], dropped = dedupe(entity, df, rejects)
        dedup_total += dropped

    date_from = pd.Timestamp(manifest["date_from"])
    date_to = pd.Timestamp(manifest["date_to"]) + pd.Timedelta(days=1)  # รวมวันสุดท้าย

    # ----- orders -----
    o = clean["orders"]
    for col in ("order_purchase_timestamp", "order_delivered_carrier_date",
                "order_delivered_customer_date", "order_estimated_delivery_date"):
        o[col + "_ts"] = parse_ts(o[col])
    bad_ts = o["order_purchase_timestamp_ts"].isna()
    for col in ("order_delivered_carrier_date", "order_delivered_customer_date", "order_estimated_delivery_date"):
        bad_ts |= o[col].notna() & o[col + "_ts"].isna()
    o = reject_rows("orders", o, bad_ts, "DQ03", "timestamp cannot be parsed", rejects)
    o = reject_rows("orders", o, ~o["order_status"].isin(ORDER_STATUSES), "DQ05", "unknown order_status", rejects)
    outside = (o["order_purchase_timestamp_ts"] < date_from) | (o["order_purchase_timestamp_ts"] >= date_to)
    o = reject_rows("orders", o, outside, "DQ07", "purchase date outside manifest scope", rejects)
    early = o["order_delivered_customer_date_ts"].notna() & (
        o["order_delivered_customer_date_ts"] < o["order_purchase_timestamp_ts"])
    reject_rows("orders", o, early, "DQ07", "delivered before purchase; delivery_days set to NULL",
                rejects, status="WARNING")
    delivered = (o["order_status"] == "delivered") & o["order_delivered_customer_date_ts"].notna() & ~early
    days = (o["order_delivered_customer_date_ts"] - o["order_purchase_timestamp_ts"]).dt.total_seconds() / 86400
    o["delivery_days"] = [money(d) if ok else None for d, ok in zip(days, delivered)]
    late = o["order_delivered_customer_date_ts"].dt.normalize() > o["order_estimated_delivery_date_ts"].dt.normalize()
    o["late_flag"] = pd.array([(1 if lt else 0) if ok and pd.notna(est) else None
                               for lt, ok, est in zip(late, delivered, o["order_estimated_delivery_date_ts"])],
                              dtype="Int16")
    o["purchase_date"] = o["order_purchase_timestamp_ts"].dt.date
    orders_ok = set(o["order_id"])

    # ----- order_items -----
    i = clean["order_items"]
    i["price_d"] = i["price"].map(lambda v: money(v) if _is_number(v) else None)
    i["freight_d"] = i["freight_value"].map(lambda v: money(v) if _is_number(v) else None)
    i["shipping_limit_ts"] = parse_ts(i["shipping_limit_date"])
    bad = i["price_d"].isna() | i["freight_d"].isna() | ~i["order_item_id"].map(_is_int)
    i = reject_rows("order_items", i, bad, "DQ03", "price, freight_value or order_item_id is not numeric", rejects)
    neg = i["price_d"].map(lambda d: d < 0) | i["freight_d"].map(lambda d: d < 0)
    i = reject_rows("order_items", i, neg, "DQ06", "negative monetary value", rejects)
    i = reject_rows("order_items", i, ~i["order_id"].isin(orders_ok), "DQ08",
                    "order not accepted in this batch", rejects)

    # ----- payments -----
    p = clean["payments"]
    p["value_d"] = p["payment_value"].map(lambda v: money(v) if _is_number(v) else None)
    bad = p["value_d"].isna() | ~p["payment_sequential"].map(_is_int) \
        | ~p["payment_installments"].map(_is_int)
    p = reject_rows("payments", p, bad, "DQ03", "payment fields are not numeric", rejects)
    p = reject_rows("payments", p, ~p["payment_type"].isin(PAYMENT_TYPES), "DQ05", "unknown payment_type", rejects)
    p = reject_rows("payments", p, p["value_d"].map(lambda d: d < 0), "DQ06", "negative payment_value", rejects)
    p = reject_rows("payments", p, ~p["order_id"].isin(orders_ok), "DQ08", "order not accepted in this batch", rejects)

    # ----- คำสั่งซื้อที่มีรายการลูกถูกปฏิเสธ: พักทั้งคำสั่งซื้อ เพื่อไม่ให้ยอดของคำสั่งซื้อไม่ครบ -----
    held = {x.key.split("|")[0] for x in rejects
            if x.entity in ("order_items", "payments") and x.status in ("REJECTED", "CONFLICT") and x.rule != "DQ08"}
    o = reject_rows("orders", o, o["order_id"].isin(held), "DQ08", "order held: an item or payment was rejected", rejects)
    i = reject_rows("order_items", i, i["order_id"].isin(held), "DQ08", "order held: sibling row rejected", rejects)
    p = reject_rows("payments", p, p["order_id"].isin(held), "DQ08", "order held: sibling row rejected", rejects)
    orders_ok = set(o["order_id"])

    i = i.merge(o[["order_id", "customer_id", "order_status", "purchase_date", "order_delivered_carrier_date_ts"]],
                on="order_id", how="left")
    carrier = i["order_delivered_carrier_date_ts"]
    i["on_time_flag"] = pd.array([None if pd.isna(c) or pd.isna(lim) else (1 if c <= lim else 0)
                                  for c, lim in zip(carrier, i["shipping_limit_ts"])], dtype="Int16")
    p = p.merge(o[["order_id", "customer_id", "purchase_date"]], on="order_id", how="left")

    # ----- reviews -----
    r = clean["reviews"]
    r["review_ts"] = parse_ts(r["review_creation_date"])
    r = reject_rows("reviews", r, r["review_ts"].isna(), "DQ03", "review_creation_date cannot be parsed", rejects)
    r = reject_rows("reviews", r, ~r["review_score"].isin(["1", "2", "3", "4", "5"]), "DQ05",
                    "review_score must be 1-5", rejects)
    r = reject_rows("reviews", r, ~r["order_id"].isin(orders_ok), "DQ08", "order not accepted in this batch", rejects)
    r = r.merge(o[["order_id", "customer_id"]], on="order_id", how="left")

    # ----- DQ06: ยอดชำระเทียบยอดสินค้า+ค่าส่ง (ระดับคำสั่งซื้อ, เตือนไม่ปฏิเสธ) -----
    sales = i.groupby("order_id")["price_d"].apply(lambda s: sum(s, Decimal("0")))
    freight = i.groupby("order_id")["freight_d"].apply(lambda s: sum(s, Decimal("0")))
    paid = p.groupby("order_id")["value_d"].apply(lambda s: sum(s, Decimal("0")))
    o["total_sales"] = o["order_id"].map(sales).map(lambda v: v if isinstance(v, Decimal) else Decimal("0.00"))
    o["total_freight"] = o["order_id"].map(freight).map(lambda v: v if isinstance(v, Decimal) else Decimal("0.00"))
    o["total_payment"] = o["order_id"].map(paid).map(lambda v: v if isinstance(v, Decimal) else Decimal("0.00"))
    gap = [(ts + tf - tp).copy_abs() > Decimal("0.01") and tp > 0 and (ts + tf) > 0
           for ts, tf, tp in zip(o["total_sales"], o["total_freight"], o["total_payment"])]
    reject_rows("orders", o, pd.Series(gap, index=o.index), "DQ06",
                "total_payment differs from items + freight", rejects, status="WARNING")

    # ----- master data -----
    c = clean["customers"]
    if hmac_key is None:
        raise BatchError("HMAC key is required to pseudonymize customer_unique_id")
    c["customer_unique_id"] = c["customer_unique_id"].map(lambda v: pseudonymize(v, hmac_key))
    c["state_ok"] = c["customer_state"].map(_is_state)
    reject_rows("customers", c, ~c["state_ok"], "DQ05", "invalid state code; stored as NULL", rejects, "WARNING")
    no_cust = ~o["customer_id"].isin(set(c["customer_id"]))
    reject_rows("orders", o, no_cust, "DQ08", "customer not in batch; inferred member will be created",
                rejects, status="WARNING")

    s = clean["sellers"]
    s["state_ok"] = s["seller_state"].map(_is_state)
    reject_rows("sellers", s, ~s["state_ok"], "DQ05", "invalid state code; stored as NULL", rejects, "WARNING")

    pr = clean["products"]
    tr = clean.get("category_translation")
    names = dict(zip(tr["product_category_name"], tr["product_category_name_english"])) if tr is not None else {}

    stage = {
        "customer": pd.DataFrame({
            "customer_id": c["customer_id"], "customer_unique_id": c["customer_unique_id"],
            "zip_code_prefix": c["customer_zip_code_prefix"].map(_zip), "city": c["customer_city"],
            "state": c["customer_state"].where(c["state_ok"], None)}),
        "seller": pd.DataFrame({
            "seller_id": s["seller_id"], "zip_code_prefix": s["seller_zip_code_prefix"].map(_zip),
            "city": s["seller_city"], "state": s["seller_state"].where(s["state_ok"], None)}),
        "product": pd.DataFrame({
            "product_id": pr["product_id"], "category_name": pr["product_category_name"],
            "category_english": pr["product_category_name"].map(lambda n: names.get(n) if pd.notna(n) else None)}),
        "order_header": pd.DataFrame({
            "order_id": o["order_id"], "customer_id": o["customer_id"], "order_status": o["order_status"],
            "purchase_date": o["purchase_date"], "total_sales": o["total_sales"],
            "total_freight": o["total_freight"], "total_payment": o["total_payment"],
            "delivery_days": o["delivery_days"], "late_flag": o["late_flag"]}),
        "order_item": pd.DataFrame({
            "order_id": i["order_id"], "order_item_id": i["order_item_id"].astype(int),
            "customer_id": i["customer_id"], "seller_id": i["seller_id"], "product_id": i["product_id"],
            "order_status": i["order_status"], "purchase_date": i["purchase_date"], "price": i["price_d"],
            "freight_value": i["freight_d"], "on_time_flag": i["on_time_flag"]}),
        "payment": pd.DataFrame({
            "order_id": p["order_id"], "payment_sequential": p["payment_sequential"].astype(int),
            "customer_id": p["customer_id"], "purchase_date": p["purchase_date"],
            "payment_type": p["payment_type"], "payment_installments": p["payment_installments"].astype(int),
            "payment_value": p["value_d"]}),
        "review": pd.DataFrame({
            "review_id": r["review_id"], "order_id": r["order_id"], "customer_id": r["customer_id"],
            "review_date": r["review_ts"].dt.date, "review_score": r["review_score"].astype(int)}),
    }
    dates = set(stage["order_header"]["purchase_date"]) | set(stage["review"]["review_date"])
    stage["calendar"] = pd.DataFrame({"full_date": sorted(dates)})
    for name, cols in STAGE_COLUMNS.items():
        if name in stage:
            stage[name] = stage[name][cols].reset_index(drop=True)

    accepted = sum(len(stage[n]) for n in ("customer", "seller", "product", "order_header",
                                            "order_item", "payment", "review"))
    accepted += len(tr) if tr is not None else 0
    return TransformResult(stage=stage, rejects=rejects, raw_rows=raw_rows,
                           accepted_rows=accepted, deduplicated_rows=dedup_total)


def _is_int(v) -> bool:
    return isinstance(v, str) and v.isdigit()


def _is_state(v) -> bool:
    return isinstance(v, str) and STATE_RE.fullmatch(v) is not None


def _is_number(v) -> bool:
    return isinstance(v, str) and re.fullmatch(r"-?\d+(\.\d+)?", v) is not None


def _zip(v):
    return None if pd.isna(v) else str(v).zfill(5)[:5]


def rejects_frame(batch_id: int, rejects: list[Reject]) -> pd.DataFrame:
    return pd.DataFrame([{"batch_id": batch_id, "entity_type": x.entity, "source_row_number": x.row,
                          "business_key": x.key[:200], "rule_code": x.rule, "record_status": x.status,
                          "error_detail": x.detail[:1000]} for x in rejects], columns=STAGE_COLUMNS["reject"])


# ---------------------------------------------------------------------------
# การส่งคำสั่งไปยังคลังข้อมูล
# ---------------------------------------------------------------------------
def sql_literal(v) -> str:
    if v is None or (not isinstance(v, (str, Decimal)) and pd.isna(v)):
        return "NULL"
    if isinstance(v, (numbers.Integral, Decimal)) and not isinstance(v, bool):
        return str(int(v)) if isinstance(v, numbers.Integral) else str(v)
    if isinstance(v, float):
        return repr(v)
    return "'" + str(v).replace("'", "''") + "'"


def q(v) -> str:
    return sql_literal(v)


class RedshiftDataApi:
    """Production: Amazon Redshift Data API — ใช้สิทธิ์ IAM (LabRole) และ Secret ใน Secrets Manager
    batch_execute_statement รันทุกคำสั่งเป็นธุรกรรมเดียว"""

    def __init__(self, cluster_id: str, database: str, secret_arn: str):
        import boto3
        self.client = boto3.client("redshift-data")
        self.base = {"ClusterIdentifier": cluster_id, "Database": database, "SecretArn": secret_arn}

    def _wait(self, sid: str) -> dict:
        while True:
            d = self.client.describe_statement(Id=sid)
            if d["Status"] in ("FINISHED", "FAILED", "ABORTED"):
                if d["Status"] != "FINISHED":
                    raise RuntimeError(d.get("Error", d["Status"]))
                return d
            time.sleep(2)

    def query(self, sql: str) -> list[list]:
        d = self._wait(self.client.execute_statement(Sql=sql, **self.base)["Id"])
        if not d.get("HasResultSet"):
            return []
        out = self.client.get_statement_result(Id=d["Id"])["Records"]
        return [[next(iter(cell.values())) if not cell.get("isNull") else None for cell in row] for row in out]

    def transaction(self, statements: list[str]) -> None:
        if len(statements) > 40:  # Data API รับได้ครั้งละไม่เกิน 40 คำสั่งต่อธุรกรรม
            raise RuntimeError(f"Transaction has {len(statements)} statements; the Data API limit is 40")
        self._wait(self.client.batch_execute_statement(Sqls=statements, **self.base)["Id"])


class LocalPsql:
    """ทดสอบในเครื่อง: PostgreSQL ผ่าน psql (--single-transaction ให้พฤติกรรมเดียวกับ Data API)"""

    def __init__(self, dsn: str):
        self.dsn = dsn

    def query(self, sql: str) -> list[list]:
        out = subprocess.run(["psql", self.dsn, "-v", "ON_ERROR_STOP=1", "-At", "-F", "\t", "-c", sql],
                             check=True, capture_output=True, text=True).stdout
        return [line.split("\t") for line in out.splitlines() if line]

    def transaction(self, statements: list[str]) -> None:
        script = ";\n".join(statements) + ";\n"
        res = subprocess.run(["psql", self.dsn, "-v", "ON_ERROR_STOP=1", "--single-transaction", "-q"],
                             input=script, capture_output=True, text=True)
        if res.returncode:
            errors = [ln for ln in res.stderr.splitlines() if "ERROR:" in ln]
            raise RuntimeError(errors[0].split("ERROR:", 1)[1].strip() if errors else "psql failed")


class S3ParquetStager:
    """Production: เขียน Parquet ลง S3 Curated Zone แล้ว COPY เข้า stg"""

    def __init__(self, curated_prefix: str, iam_role: str):
        self.prefix, self.iam_role = curated_prefix.rstrip("/"), iam_role

    def statements(self, batch_id: int, table: str, df: pd.DataFrame) -> list[str]:
        import awswrangler as wr
        path = f"{self.prefix}/batch_id={batch_id}/{table}/"
        if len(df):
            types = {c: PARQUET_TYPES.get(c, "string") for c in df.columns}
            wr.s3.to_parquet(df=df, path=path, dataset=True, mode="overwrite", dtype=types, index=False)
        sqls = [f"DELETE FROM stg.{table}"]
        if len(df):
            sqls.append(f"COPY stg.{table} FROM {q(path)} IAM_ROLE {q(self.iam_role)} FORMAT AS PARQUET")
        return sqls


class InlineStager:
    """ทดสอบในเครื่อง: แปลงแถวเป็น INSERT ... VALUES"""

    def statements(self, batch_id: int, table: str, df: pd.DataFrame) -> list[str]:
        sqls = [f"DELETE FROM stg.{table}"]
        cols = ",".join(df.columns)
        rows = [f"({','.join(sql_literal(v) for v in rec)})" for rec in df.itertuples(index=False, name=None)]
        for start in range(0, len(rows), 1000):
            sqls.append(f"INSERT INTO stg.{table} ({cols}) VALUES " + ",".join(rows[start:start + 1000]))
        return sqls


# ---------------------------------------------------------------------------
# ลำดับการทำงานของหนึ่งรอบโหลด
# ---------------------------------------------------------------------------
def register_batch(db, manifest: dict, manifest_sha: str, source_prefix: str) -> tuple[int, str]:
    where = f"batch_name = {q(manifest['batch_name'])} AND manifest_sha256 = {q(manifest_sha)}"
    rows = db.query(f"SELECT batch_id, status FROM ops.load_batch WHERE {where}")
    if not rows:
        db.transaction([
            "LOCK ops.load_batch",
            "INSERT INTO ops.load_batch (batch_name, manifest_sha256, contract_version, source_prefix, "
            "business_date_from, business_date_to, status) "
            f"SELECT {q(manifest['batch_name'])}, {q(manifest_sha)}, {q(manifest['contract_version'])}, "
            f"{q(source_prefix)}, {q(manifest['date_from'])}, {q(manifest['date_to'])}, 'RECEIVED' "
            f"WHERE NOT EXISTS (SELECT 1 FROM ops.load_batch WHERE {where})",
        ])
        rows = db.query(f"SELECT batch_id, status FROM ops.load_batch WHERE {where}")
    return int(rows[0][0]), str(rows[0][1])


def warehouse_statements(batch_id: int, result: TransformResult, stager) -> list[str]:
    sqls = [
        "LOCK ops.load_batch",
        f"UPDATE ops.load_batch SET status = 'VALIDATED', raw_row_count = {result.raw_rows}, "
        f"accepted_row_count = {result.accepted_rows}, rejected_row_count = {result.rejected_rows}, "
        f"deduplicated_row_count = {result.deduplicated_rows}, warning_row_count = {result.warning_rows}, "
        f"error_message = NULL WHERE batch_id = {batch_id}",
        f"DELETE FROM ops.reject_record WHERE batch_id = {batch_id}",
    ]
    order = ["customer", "seller", "product", "calendar", "order_header", "order_item", "payment", "review"]
    for table in order:
        sqls += stager.statements(batch_id, table, result.stage[table])
    sqls += stager.statements(batch_id, "reject", rejects_frame(batch_id, result.rejects))
    sqls += [
        "INSERT INTO ops.reject_record (batch_id, entity_type, source_row_number, business_key, rule_code, "
        "record_status, error_detail) SELECT batch_id, entity_type, source_row_number, business_key, rule_code, "
        "record_status, error_detail FROM stg.reject",
        f"CALL ops.sp_load_batch({batch_id})",
        f"CALL ops.sp_publish({batch_id})",
    ]
    return sqls


def mark_failed(db, batch_id: int, message: str, result: TransformResult | None, stager) -> None:
    sqls = [f"UPDATE ops.load_batch SET status = 'FAILED', finished_at = GETDATE(), "
            f"error_message = {q(message[:4000])} WHERE batch_id = {batch_id}"]
    if result is not None:
        sqls.append(f"DELETE FROM ops.reject_record WHERE batch_id = {batch_id}")
        sqls += stager.statements(batch_id, "reject", rejects_frame(batch_id, result.rejects))
        sqls.append("INSERT INTO ops.reject_record (batch_id, entity_type, source_row_number, business_key, "
                    "rule_code, record_status, error_detail) SELECT batch_id, entity_type, source_row_number, "
                    "business_key, rule_code, record_status, error_detail FROM stg.reject")
    db.transaction(sqls)


def run_batch(store, db, stager, source_prefix: str, hmac_key: bytes | None, notify=None) -> dict:
    manifest, manifest_sha = read_manifest(store)  # Manifest อ่านไม่ได้ = ลงทะเบียนรอบไม่ได้ หยุดทันที
    batch_id, status = register_batch(db, manifest, manifest_sha, source_prefix)
    if status == "PUBLISHED":  # DQ11: Replay manifest เดิมไม่เปลี่ยนคลังข้อมูล
        return {"batch_id": batch_id, "status": "PUBLISHED", "skipped": True}
    result = None
    try:
        frames = read_frames(store, manifest)          # DQ01 DQ02
        result = transform(manifest, frames, hmac_key)  # DQ03-DQ08
        db.transaction(warehouse_statements(batch_id, result, stager))  # DQ09 DQ10 ใน Procedure
    except Exception as e:  # noqa: BLE001 — บันทึกสถานะแล้วส่งต่อให้ Glue/Lambda ทราบ
        mark_failed(db, batch_id, f"{type(e).__name__}: {e}", result, stager)
        if notify:
            notify(f"Olytics batch {manifest['batch_name']} (#{batch_id}) FAILED: {e}")
        raise
    summary = {"batch_id": batch_id, "status": "PUBLISHED", "raw": result.raw_rows,
               "accepted": result.accepted_rows, "rejected": result.rejected_rows,
               "warnings": result.warning_rows, "deduplicated": result.deduplicated_rows}
    if notify:
        notify(f"Olytics batch {manifest['batch_name']} (#{batch_id}) PUBLISHED: {json.dumps(summary)}")
    return summary


def glue_main() -> None:
    import sys
    import boto3
    from awsglue.utils import getResolvedOptions  # มีให้ใน AWS Glue runtime
    args = getResolvedOptions(sys.argv, ["RAW_PREFIX", "CURATED_PREFIX", "REDSHIFT_CLUSTER_ID",
                                         "REDSHIFT_DATABASE", "REDSHIFT_SECRET_ARN", "COPY_IAM_ROLE",
                                         "HMAC_SECRET_ID", "SNS_TOPIC_ARN"])
    key = boto3.client("secretsmanager").get_secret_value(SecretId=args["HMAC_SECRET_ID"])["SecretString"]
    sns = boto3.client("sns")

    def notify(msg: str) -> None:
        if args["SNS_TOPIC_ARN"] != "none":
            sns.publish(TopicArn=args["SNS_TOPIC_ARN"], Subject="Olytics ETL", Message=msg[:250000])

    db = RedshiftDataApi(args["REDSHIFT_CLUSTER_ID"], args["REDSHIFT_DATABASE"], args["REDSHIFT_SECRET_ARN"])
    print(json.dumps(run_batch(S3Store(args["RAW_PREFIX"]), db,
                               S3ParquetStager(args["CURATED_PREFIX"], args["COPY_IAM_ROLE"]),
                               args["RAW_PREFIX"], key.encode("utf-8"), notify)))


def local_main() -> None:
    ap = argparse.ArgumentParser(description="Run one Olist batch against a local PostgreSQL test warehouse")
    ap.add_argument("--local", required=True, help="folder that holds manifest.json and the CSV files")
    ap.add_argument("--psql-dsn", required=True)
    a = ap.parse_args()
    key = os.environ.get("OLYTICS_HMAC_KEY", "").encode("utf-8") or None
    print(json.dumps(run_batch(LocalStore(a.local), LocalPsql(a.psql_dsn), InlineStager(),
                               os.path.abspath(a.local), key)))


if __name__ == "__main__":
    import sys
    if "--local" in sys.argv:
        local_main()
    else:
        glue_main()
```

#### ส่วนที่ 2 lambda_trigger.py (S3 Event → AWS Glue Job)

*ไฟล์:* `lambda_trigger.py`

```python
"""lambda_trigger.py — S3 Event Notification -> AWS Glue Job (เอกสาร DW-OLYTICS-001 ภาคผนวก ค ส่วนที่ 2)

ตั้ง S3 Event Notification (ObjectCreated) ที่ prefix raw/ และ suffix manifest.json
ผู้ส่งข้อมูลต้องอัปโหลด manifest.json เป็นไฟล์สุดท้ายของชุด เพื่อให้ Glue เริ่มเมื่อไฟล์ครบ
Environment: GLUE_JOB_NAME, CURATED_PREFIX, SNS_TOPIC_ARN (ไม่บังคับ)
"""
import json
import os
import re
import urllib.parse

import boto3

glue = boto3.client("glue")
sns = boto3.client("sns")
MANIFEST_KEY = re.compile(r"^raw/batch=[A-Za-z0-9_\-]{1,64}/manifest\.json$")


def _notify(message: str) -> None:
    topic = os.environ.get("SNS_TOPIC_ARN")
    if topic:
        sns.publish(TopicArn=topic, Subject="Olytics ETL trigger", Message=message[:250000])


def handler(event, context):
    started = []
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
        if not MANIFEST_KEY.match(key):
            continue  # ไม่ใช่ manifest ของชุดข้อมูล — ข้าม
        raw_prefix = f"s3://{bucket}/{key.rsplit('/', 1)[0]}/"
        try:
            run = glue.start_job_run(
                JobName=os.environ["GLUE_JOB_NAME"],
                Arguments={"--RAW_PREFIX": raw_prefix, "--CURATED_PREFIX": os.environ["CURATED_PREFIX"]},
            )
            started.append({"raw_prefix": raw_prefix, "job_run_id": run["JobRunId"]})
        except glue.exceptions.ConcurrentRunsExceededException:
            # Learner Lab จำกัด Glue Concurrency = 1: แจ้งผู้ดูแลแล้วโยนข้อผิดพลาดให้ Lambda Retry (Async)
            _notify(f"Glue job busy; batch {raw_prefix} will be retried by Lambda")
            raise
    return {"statusCode": 200, "body": json.dumps(started)}
```

### ภาคผนวก ง การกำหนดสิทธิ์และ Security Views (003_security.sql)

สร้าง Role ฐานข้อมูลตามหลักสิทธิ์น้อยที่สุด View ปิดบังข้อมูล v_user_analytics และตัวอย่าง Row-Level Security ระดับรัฐของ Redshift สำหรับระยะที่ 2

*ไฟล์:* `003_security.sql`

```sql
-- =====================================================================
-- 003_security.sql | Olytics Data Warehouse | Amazon Redshift RBAC
-- เอกสารอ้างอิง DW-OLYTICS-001 ภาคผนวก ง
-- รันโดยบัญชี Migration Owner (ผู้ดูแลคลังข้อมูล) หลัง 001 และ 002
-- รหัสผ่านของบัญชีจริงสร้างและหมุนเวียนผ่าน AWS Secrets Manager โดย DBA แยกจากสคริปต์นี้
-- =====================================================================

-- ---------- 1) Role ฐานข้อมูล ----------
CREATE ROLE etl_loader;          -- Glue Job / warehouse_loader.py
CREATE ROLE dashboard_reader;    -- olytics-web (Next.js) และ ec2-api: อ่าน KPI View เท่านั้น
CREATE ROLE analyst_reader;      -- นักวิเคราะห์ / Query Lab ที่ต้องการระดับรายละเอียด (ข้อมูลลดการระบุตัวบุคคล)
CREATE ROLE ops_auditor;         -- ตรวจสอบรอบโหลด / ผู้ตรวจสอบภายนอก

REVOKE ALL ON SCHEMA ops, stg, dw FROM PUBLIC;

-- ---------- 2) etl_loader: เขียน stg/dw/ops และเรียก Procedure ----------
GRANT USAGE ON SCHEMA ops, stg, dw TO ROLE etl_loader;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ops TO ROLE etl_loader;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA stg TO ROLE etl_loader;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA dw  TO ROLE etl_loader;
GRANT EXECUTE ON PROCEDURE ops.sp_load_batch(BIGINT) TO ROLE etl_loader;
GRANT EXECUTE ON PROCEDURE ops.sp_publish(BIGINT)    TO ROLE etl_loader;

-- ---------- 3) dashboard_reader: SELECT เฉพาะ 15 KPI Views ----------
GRANT USAGE ON SCHEMA dw TO ROLE dashboard_reader;
GRANT SELECT ON
  dw.v_br01_monthly_sales, dw.v_br02_top_states, dw.v_br02_top_categories,
  dw.v_br03_payment_distribution, dw.v_br04_category_performance,
  dw.v_br05_seller_performance, dw.v_br06_seller_on_time,
  dw.v_br07_sellers_without_revenue, dw.v_br08_late_delivery,
  dw.v_br09_delivery_days, dw.v_br10_review_satisfaction,
  dw.v_br11_repeat_customers, dw.v_br12_order_failure_rate,
  dw.v_br13_customer_geography, dw.v_br14_monthly_category_sales
TO ROLE dashboard_reader;

-- ---------- 4) View สำหรับนักวิเคราะห์ที่ปกปิดข้อมูล (Data Masking บน View) ----------
-- customer_unique_id ถูกแปลงด้วย HMAC-SHA256 ตั้งแต่ขั้นตอน ETL (Pseudonymization)
-- View นี้ปิดรหัสไปรษณีย์เหลือ 2 หลักแรก และไม่เปิด customer_id ระดับคำสั่งซื้อ
CREATE OR REPLACE VIEW dw.v_user_analytics AS
WITH o AS (
  SELECT c.customer_unique_id, c.state, c.city, c.zip_code_prefix, d.full_date,
         f.order_id, f.total_sales, os.order_status,
         ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY d.full_date DESC, f.order_key DESC) AS rn
    FROM dw.fact_order f
    JOIN dw.dim_customer c      ON c.customer_key      = f.customer_key
    JOIN dw.dim_date d          ON d.date_key          = f.purchase_date_key
    JOIN dw.dim_order_status os ON os.order_status_key = f.order_status_key
   WHERE c.customer_key <> -1
)
SELECT customer_unique_id AS customer_pseudo_id,
       MAX(CASE WHEN rn = 1 THEN state END) AS latest_state,
       MAX(CASE WHEN rn = 1 THEN city END)  AS latest_city,
       MAX(CASE WHEN rn = 1 THEN LEFT(COALESCE(zip_code_prefix, ''), 2) || 'xxx' END) AS zip_code_masked,
       MIN(full_date) AS first_purchase_date,
       MAX(full_date) AS last_purchase_date,
       COUNT(DISTINCT CASE WHEN order_status NOT IN ('canceled', 'unavailable') THEN order_id END) AS counted_orders,
       SUM(CASE WHEN order_status NOT IN ('canceled', 'unavailable') THEN total_sales ELSE 0 END) AS total_sales
  FROM o
 GROUP BY customer_unique_id;

GRANT USAGE ON SCHEMA dw TO ROLE analyst_reader;
GRANT SELECT ON
  dw.v_br01_monthly_sales, dw.v_br02_top_states, dw.v_br02_top_categories,
  dw.v_br03_payment_distribution, dw.v_br04_category_performance,
  dw.v_br05_seller_performance, dw.v_br06_seller_on_time,
  dw.v_br07_sellers_without_revenue, dw.v_br08_late_delivery,
  dw.v_br09_delivery_days, dw.v_br10_review_satisfaction,
  dw.v_br11_repeat_customers, dw.v_br12_order_failure_rate,
  dw.v_br13_customer_geography, dw.v_br14_monthly_category_sales,
  dw.vw_sale_items, dw.vw_orders, dw.vw_latest_review,
  dw.v_user_analytics, dw.dim_date, dw.dim_product, dw.dim_seller,
  dw.dim_order_status, dw.dim_payment_method, dw.dim_review_score
TO ROLE analyst_reader;
-- หมายเหตุ: analyst_reader ไม่ได้รับสิทธิ์ dw.dim_customer และ Fact โดยตรง (อ่านผ่าน View ที่ปกปิดแล้ว)

-- ---------- 5) ops_auditor: อ่านบันทึกการโหลดและการกระทบยอด ----------
GRANT USAGE ON SCHEMA ops TO ROLE ops_auditor;
GRANT SELECT ON ops.load_batch, ops.reject_record, ops.publish_state TO ROLE ops_auditor;

-- ---------- 6) ผูกบัญชีผู้ใช้กับ Role (DBA สร้างบัญชีและรหัสผ่านผ่าน Secrets Manager) ----------
-- CREATE USER olytics_etl     PASSWORD '<จาก Secrets Manager>';
-- CREATE USER olytics_web     PASSWORD '<จาก Secrets Manager>';   -- REDSHIFT_USER ของ olytics-web
-- CREATE USER olytics_api_ro  PASSWORD '<จาก Secrets Manager>';   -- ec2-api (olist-api.service)
-- GRANT ROLE etl_loader       TO olytics_etl;
-- GRANT ROLE dashboard_reader TO olytics_web;
-- GRANT ROLE dashboard_reader TO olytics_api_ro;

-- ===== REDSHIFT-ONLY: ส่วนต่อจากนี้ใช้ไวยากรณ์ RLS ของ Amazon Redshift =====
-- ---------- 7) (ระยะที่ 2) Row-Level Security ระดับรัฐของผู้ขาย ----------
-- ใช้เมื่อเปิดบัญชีฐานข้อมูลรายบุคคลให้ผู้จัดการพื้นที่ (Regional/Seller Manager)
-- olytics-web ปัจจุบันใช้บัญชีกลางหนึ่งบัญชีและบังคับสิทธิ์ที่ middleware.ts จึงยังไม่พึ่ง RLS นี้
CREATE ROLE seller_scoped_reader;
GRANT USAGE ON SCHEMA dw TO ROLE seller_scoped_reader;
GRANT SELECT ON dw.v_br05_seller_performance, dw.v_br06_seller_on_time TO ROLE seller_scoped_reader;

CREATE RLS POLICY rls_seller_state
WITH (seller_state CHAR(2))
USING (seller_state IN (SELECT a.state FROM ops.state_access a WHERE a.login_name = current_user));
GRANT SELECT ON ops.state_access TO RLS POLICY rls_seller_state;

ATTACH RLS POLICY rls_seller_state ON dw.v_br05_seller_performance TO ROLE seller_scoped_reader;
ATTACH RLS POLICY rls_seller_state ON dw.v_br06_seller_on_time     TO ROLE seller_scoped_reader;
ALTER TABLE dw.v_br05_seller_performance ROW LEVEL SECURITY ON;
ALTER TABLE dw.v_br06_seller_on_time     ROW LEVEL SECURITY ON;
```
