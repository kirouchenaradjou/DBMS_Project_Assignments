-- -----------------------------------------------------
-- Schema HealthcareInsuranceManagementSystem
-- -----------------------------------------------------
USE Team4_HospitalManagementSystem;

-- Create Database Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PasswordForGroup4';

-- Create self signed certificate
CREATE CERTIFICATE Certificate1
WITH SUBJECT = 'Protect Data';

-- Create SYMMETRIC Key
CREATE SYMMETRIC KEY SymmetricKey1 
WITH ALGORITHM = AES_128 
ENCRYPTION BY CERTIFICATE Certificate1;


-- Create Helper functions
GO
CREATE FUNCTION dbo.fnCheckDate
(@InDate datetime)
RETURNS DATETIME
AS
    BEGIN
        declare @Return DATETIME

        select @return = CASE WHEN ISDATE(@InDate) = 1
                            THEN CASE WHEN CAST(@InDate as DATETIME) BETWEEN '1/1/1901 12:00:00 AM' AND '6/6/2079 12:00:00 AM'
                                    THEN @InDate
                                    ELSE null
                                    END
                            ELSE null
                            END
        return @return
    END
GO
-- -----------------------------------------------------
-- Table "User"
-- -----------------------------------------------------
CREATE TABLE "User" (
	UserID INT NOT NULL,
	FirstName VARCHAR(25) NOT NULL,
	LastName  VARCHAR(25) NOT NULL,
	UserName  VARCHAR(15) NOT NULL,
	"Password" VARBINARY(MAX) NOT NULL,
	Address1  VARCHAR(25) NOT NULL,
	Address2  VARCHAR(25) NULL,
	City  VARCHAR(25) NOT NULL,
	State  VARCHAR(25) NOT NULL,
	ZipCode  VARCHAR(25) NOT NULL,
  PRIMARY KEY (UserID)
);

-- -----------------------------------------------------
-- Table "Admin"
-- -----------------------------------------------------
CREATE TABLE "Admin" (
	AdminID INT NOT NULL,
	UserID INT NOT NULL,
  PRIMARY KEY (AdminID),
  CONSTRAINT fkAdminUser
		FOREIGN KEY (UserID) REFERENCES "User" (UserID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "customer"
-- -----------------------------------------------------
CREATE TABLE Customer (
	CustomerID INT NOT NULL,
	UserID INT NOT NULL,
  PRIMARY KEY (CustomerID),
  CONSTRAINT fkCustomerUser
	  FOREIGN KEY (CustomerID) REFERENCES "User" (UserID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "hospital"
-- -----------------------------------------------------
CREATE TABLE Hospital (
  HospitalID INT NOT NULL,
	Name VARCHAR(25) NOT NULL,
	Address1  VARCHAR(25) NOT NULL,
	Address2  VARCHAR(25) NULL,
	City  VARCHAR(25) NOT NULL,
	State  VARCHAR(25) NOT NULL,
	ZipCode  VARCHAR(25) NOT NULL,
  PRIMARY KEY (HospitalID)
);

-- -----------------------------------------------------
-- Table "doctor"
-- -----------------------------------------------------
CREATE TABLE Doctor ( 
	DoctorID INT NOT NULL,
	HospitalID INT NOT NULL,
	UserID INT NOT NULL,
	Designation VARCHAR(25) NOT NULL,
	Specialization VARCHAR(15) NOT NULL,
  PRIMARY KEY (DoctorID),
  CONSTRAINT fkDoctorHospital
    FOREIGN KEY (HospitalID) REFERENCES Hospital (HospitalID)
    ON DELETE CASCADE,
  CONSTRAINT fkDoctorUser
    FOREIGN KEY (UserID) REFERENCES "User" (UserID)
);

-- -----------------------------------------------------
-- Table "DoctorCustomer"
-- -----------------------------------------------------
CREATE TABLE DoctorCustomer (
	CustomerID INT NOT NULL,
	DoctorID INT NOT NULL,
	PRIMARY KEY(CustomerID, DoctorID),
  CONSTRAINT fkDoctorHasCustomerCustomer
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE CASCADE,
  CONSTRAINT fkDoctorHasCustomerDoctor
    FOREIGN KEY (DoctorID) REFERENCES Doctor (DoctorID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "Agent"
-- -----------------------------------------------------
CREATE TABLE Agent (
  AgentID INT NOT NULL,
  UserID INT NOT NULL,
  PRIMARY KEY (AgentID),
  CONSTRAINT fkAgentUser
    FOREIGN KEY (UserID) REFERENCES "User" (UserID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "Agent_customer"
-- -----------------------------------------------------
CREATE TABLE AgentCustomer (
	CustomerID INT NOT NULL,
	AgentID INT NOT NULL,
	PRIMARY KEY(CustomerID, AgentID),
  CONSTRAINT fkAgentHasCustomerAgent
    FOREIGN KEY (AgentID) REFERENCES Agent (AgentID)
    ON DELETE CASCADE,
  CONSTRAINT fkAgentHasCustomerCustomer
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE NO ACTION
);

-- -----------------------------------------------------
-- Table "Insurance"
-- -----------------------------------------------------
CREATE TABLE Insurance (
	InsuranceID INT NOT NULL,
	Name VARCHAR(25) NOT NULL,
  PRIMARY KEY (InsuranceID)
);

-- -----------------------------------------------------
-- Table "Premium"
-- -----------------------------------------------------
CREATE TABLE Premium (
  PremiumID INT NOT NULL,
  Amount MONEY NOT NULL,
  Name VARCHAR(45) NOT NULL,
  CoPay FLOAT NOT NULL,
  CoveredAmount AS (100 - CoPay) PERSISTED,
  InsuranceID INT NOT NULL,
  PRIMARY KEY (PremiumID, InsuranceID),
  CONSTRAINT fkPremiumInsurance
    FOREIGN KEY (InsuranceID) REFERENCES Insurance (InsuranceID)
    ON DELETE CASCADE,
  CONSTRAINT checkPremiumAmount
    CHECK (Amount >= 0),
  CONSTRAINT checkCoPay
    CHECK (CoPay >= 0 AND CoPay <= 100)
);

-- -----------------------------------------------------
-- Table "customer_Premium"
-- -----------------------------------------------------
CREATE TABLE CustomerPremium (
  CustomerID INT NOT NULL,
  PremiumID INT NOT NULL,
  InsuranceID INT NOT NULL,
  PRIMARY KEY (CustomerID, PremiumID),
  CONSTRAINT fkCustomerHasPremiumCustomers
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE CASCADE,
  CONSTRAINT fkCustomerHasPremiumPremiums
    FOREIGN KEY (PremiumID, InsuranceID) REFERENCES Premium (PremiumID, InsuranceID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "Disease"
-- -----------------------------------------------------
CREATE Table Disease (
  DiseaseID INT NOT NULL,
  Name VARCHAR(45) NOT NULL,
  PRIMARY KEY (DiseaseID)
);

-- -----------------------------------------------------
-- Table "customer_Disease"
-- -----------------------------------------------------
CREATE Table CustomerDisease (
  CustomerID INT NOT NULL,
  DiseaseID INT NOT NULL,
  PRIMARY KEY (CustomerID, DiseaseID),
  CONSTRAINT fkCustomerHasDiseaseCustomers
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE CASCADE,
  CONSTRAINT fkCustomerHasDiseaseDiseases
    FOREIGN KEY (DiseaseID) REFERENCES Disease (DiseaseID)
    ON DELETE NO ACTION 
);

-- -----------------------------------------------------
-- Table "MedicalRecords"
-- -----------------------------------------------------
CREATE TABLE MedicalRecords (
  MedicalRecordID INT NOT NULL,
  FileNumber VARCHAR(45) NOT NULL,
  CustomerID INT NOT NULL,
  PRIMARY KEY (MedicalRecordID),
  CONSTRAINT fkMedicalRecordsCustomer
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "Transactions"
-- -----------------------------------------------------
CREATE Table Transactions (
  TransactionID INT NOT NULL,
  PaymentType VARCHAR(45) NOT NULL,
  Amount MONEY NOT NULL,
  Taxes MONEY NOT NULL,
  TotalAmount AS (CAST(Amount AS FLOAT) + CAST(Taxes AS FLOAT)) PERSISTED,
  CustomerID INT NOT NULL,
  PRIMARY KEY (TransactionID),
  CONSTRAINT fkTransactionsCustomer
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "Immunization"
-- -----------------------------------------------------
CREATE Table Immunization (
  ImmunizationID INT NOT NULL,
  DiseaseID INT NOT NULL,
  PRIMARY KEY (ImmunizationID, DiseaseID),
  CONSTRAINT fkImmunizationDisease
    FOREIGN KEY (DiseaseID) REFERENCES Disease (DiseaseID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "ImmunizationRecord"
-- -----------------------------------------------------
CREATE TABLE ImmunizationRecord (
  ImmunizationRecordID INT NOT NULL,
  CustomerID INT NOT NULL,
  ImmunizationID INT NOT NULL,
  DiseaseID INT NOT NULL,
  PRIMARY KEY (ImmunizationRecordID),
  CONSTRAINT fkImmunizationRecordCustomer
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE CASCADE,
  CONSTRAINT fkImmunizationRecordImmunization
    FOREIGN KEY (ImmunizationID, DiseaseID) REFERENCES Immunization (ImmunizationID, DiseaseID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "ClaimStatus"
-- -----------------------------------------------------
CREATE TABLE ClaimStatus (
  ClaimStatusID INT NOT NULL,
  ClaimStatusName VARCHAR(45) NOT NULL,
  PRIMARY KEY (ClaimStatusID)
);

-- -----------------------------------------------------
-- Table "Claims"
-- -----------------------------------------------------
CREATE TABLE Claims (
  ClaimID INT NOT NULL,
  "Desc" VARCHAR(45) NULL,
  FileNumber VARCHAR(45) NOT NULL,
  CustomerID INT NOT NULL,
  PRIMARY KEY (ClaimID),
  CONSTRAINT fkClaimsCustomer
    FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
    ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Table "ClaimStatusHistory"
-- -----------------------------------------------------
CREATE TABLE ClaimStatusHistory (
  ClaimStatusHistoryID INT NOT NULL,
  "Date" TIMESTAMP NOT NULL,
  ClaimStatusID INT NOT NULL,
  ClaimID INT NOT NULL,
  PRIMARY KEY (ClaimStatusHistoryID),
  CONSTRAINT fkClaimStatusHistoryClaimStatus
    FOREIGN KEY (ClaimStatusID) REFERENCES ClaimStatus (ClaimStatusID)
    ON DELETE CASCADE,
  CONSTRAINT fkClaimStatusHistoryClaims
    FOREIGN KEY (ClaimID) REFERENCES Claims (ClaimID)
    ON DELETE CASCADE,
  CONSTRAINT check_date
    CHECK ([Date] = dbo.fnCheckDate([Date]))
);

-- Inserting Values in the table --
-- Open symmetric key for use--
OPEN SYMMETRIC KEY SymmetricKey1
DECRYPTION BY CERTIFICATE Certificate1;

INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('1', 'Kiran', 'Putra', 'kiran', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), '61 Hungitinton Avenue', 'Boston Street', 'Boston', 'MA', '02115');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('2', 'Raghavan', 'Regunathan', 'raghavan', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), '76 Mission Main', 'Boston', 'Boston', 'MA', '02116');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('3', 'Raghavi', 'Kirouchenaradjou', 'raghavi', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), '1185 Boyslton Street', 'Near Fenwat', 'Boston', 'MA', '02115');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('4', 'Deiva', 'Dhanasegaran', 'deiva', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), '51 Park Drive', 'Near NEU', 'Boston', 'MA', '02115');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('5', 'Kavitha', 'K', 'kavi', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), '56 Point Care Street', 'California', 'San Diego', 'California', '00891');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('6', 'Neha', 'Pednekar', 'neha', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), 'Mission Main', 'Near NEU', 'Boston', 'MA', '07819');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('7', 'Divya', 'Priya', 'divya', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), '116 Coventry', 'Near Ruggles', 'Boston', 'MA', '02115');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('8', 'Kevin', 'Joseph', 'kevin', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), 'Brookline', 'Near Boston Common', 'Boston', 'MA', '02819');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('9', 'Zack', 'Downs', 'zack', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), 'Waltham 1601 Trapelo Road', 'Waltham', 'Waltham', 'MA', '07182');
INSERT INTO "User" ("UserID", "FirstName", "LastName", "UserName", "Password", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('10', 'Uma', 'Devi', 'uma', EncryptByKey (Key_GUID('SymmetricKey1'), 'Password1'), '78,State Street', 'Waltham', 'Wlatham', 'MA', '01172');

CLOSE SYMMETRIC KEY SymmetricKey1;

SELECT * FROM "User";

INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('1', '1');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('2', '2');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('3', '3');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('4', '4');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('5', '5');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('6', '6');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('7', '7');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('8', '8');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('9', '9');
INSERT INTO "Admin" ("AdminID", "UserID") VALUES ('10', '10');

INSERT INTO "agent" ("AgentID", "UserID") VALUES ('1', '3');
INSERT INTO "agent" ("AgentID", "UserID") VALUES ('2', '4');
INSERT INTO "agent" ("AgentID", "UserID") VALUES ('3', '6');
INSERT INTO "agent" ("AgentID", "UserID") VALUES ('4', '9');


INSERT INTO "customer" ("CustomerID", "UserID") VALUES ('1', '1');
INSERT INTO "customer" ("CustomerID", "UserID") VALUES ('2', '2');
INSERT INTO "customer" ("CustomerID", "UserID") VALUES ('3', '5');
INSERT INTO "customer" ("CustomerID", "UserID") VALUES ('4', '7');
INSERT INTO "customer" ("CustomerID", "UserID") VALUES ('5', '8');
INSERT INTO "customer" ("CustomerID", "UserID") VALUES ('6', '10');


INSERT INTO "agentcustomer" ("CustomerID", "AgentID") VALUES ('1', '1');
INSERT INTO "agentcustomer" ("CustomerID", "AgentID") VALUES ('2', '1');
INSERT INTO "agentcustomer" ("CustomerID", "AgentID") VALUES ('3', '2');
INSERT INTO "agentcustomer" ("CustomerID", "AgentID") VALUES ('4', '1');

INSERT INTO "claims" ("ClaimID", "Desc", "FileNumber", "CustomerID") VALUES ('1', 'For Ligament Tear Operation', 'FI198198', '1');
INSERT INTO "claims" ("ClaimID", "Desc", "FileNumber", "CustomerID") VALUES ('2', 'For Ear Checkup', 'FI818908', '2');
INSERT INTO "claims" ("ClaimID", "Desc", "FileNumber", "CustomerID") VALUES ('3', 'For Heart Surgery', 'FI526772', '1');


INSERT INTO "claimstatus" ("ClaimStatusID", "ClaimStatusName") VALUES ('1', 'Approved');
INSERT INTO "claimstatus" ("ClaimStatusID", "ClaimStatusName") VALUES ('2', 'Denied');
INSERT INTO "claimstatus" ("ClaimStatusID", "ClaimStatusName") VALUES ('3', 'Approved');



INSERT INTO "disease" ("DiseaseID", "Name") VALUES ('1', 'Leg Surgery');
INSERT INTO "disease" ("DiseaseID", "Name") VALUES ('2', 'Ear Related Problems');
INSERT INTO "disease" ("DiseaseID", "Name") VALUES ('3', 'Heart Related Problem');


INSERT INTO "customerdisease" ("CustomerID", "DiseaseID") VALUES ('1', '1');
INSERT INTO "customerdisease" ("CustomerID", "DiseaseID") VALUES ('2', '2');
INSERT INTO "customerdisease" ("CustomerID", "DiseaseID") VALUES ('3', '3');


INSERT INTO "hospital" ("HospitalID", "Name", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('1', 'Boston Heart Hospital', '13,Pouvre Street', 'Boston', 'Boston', 'MA', '02113');
INSERT INTO "hospital" ("HospitalID", "Name", "Address1", "Address2", "City", "State", "ZipCode") VALUES ('2', 'Boston Emergency Hospital', '87 Park Drive', 'Boston', 'Boston', 'MA', '02782');


INSERT INTO "insurance" ("InsuranceID", "Name") VALUES ('1', 'Insurance 1');
INSERT INTO "insurance" ("InsuranceID", "Name") VALUES ('2', 'Insurance 2');
INSERT INTO "insurance" ("InsuranceID", "Name") VALUES ('3', 'Insurance 3');
INSERT INTO "insurance" ("InsuranceID", "Name") VALUES ('4', 'Insurance 4');



INSERT INTO "premium" ("PremiumID", "Amount", "Name", "CoPay", "InsuranceID") VALUES ('1', '7000', 'Prenium', '20', '1');
INSERT INTO "premium" ("PremiumID", "Amount", "Name", "CoPay", "InsuranceID") VALUES ('2', '2000', 'Gold', '40', '2');
INSERT INTO "premium" ("PremiumID", "Amount", "Name", "CoPay", "InsuranceID") VALUES ('3', '1000', 'Silver', '60', '3');
INSERT INTO "premium" ("PremiumID", "Amount", "Name", "CoPay", "InsuranceID") VALUES ('4', '500', 'Bronze', '80', '4');


-- Testing Calculated Columns
SELECT * FROM Premium; -- CoveredAmount will be present

-- Testing CHECK Constraint
-- The following should fail
INSERT INTO "premium" ("PremiumID", "Amount", "Name", "CoPay", "InsuranceID") VALUES ('5', '500', 'Bronze', '280', '4');
INSERT INTO "premium" ("PremiumID", "Amount", "Name", "CoPay", "InsuranceID") VALUES ('5', '-500', 'Bronze', '280', '4');

-- Generating reports by creating views
/*
	View 1
*/

GO
CREATE VIEW Customer_and_City_Information
AS  
SELECT FirstName, City, CustomerID, u.UserID
FROM [User] AS u
JOIN Customer AS c
ON(u.userID = c.UserID);
GO
 --Test 
SELECT * FROM Customer_and_City_Information;

/*
	View 2
*/
GO
CREATE VIEW Customer_Disease_Immunization_Info
AS
SELECT u.LastName, u.FirstName, ir.ImmunizationRecordID, d.Name
FROM ImmunizationRecord ir JOIN Immunization i
ON (i.ImmunizationID = ir.ImmunizationID)
JOIN Disease d ON (i.DiseaseID = d.DiseaseID)
JOIN Customer c ON (ir.CustomerID = c.CustomerID)
JOIN [User] U ON (c.UserID = u.UserID);
GO
 
 --Test
SELECT * FROM Customer_Disease_Immunization_Info;