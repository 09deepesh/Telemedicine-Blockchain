-- doctors table
CREATE TABLE IF NOT EXISTS doctors (
  address VARCHAR(42) PRIMARY KEY,
  name VARCHAR(100),
  specialization VARCHAR(100),
  isVerified BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- patients table
CREATE TABLE IF NOT EXISTS patients (
  address VARCHAR(42) PRIMARY KEY,
  name VARCHAR(100),
  age INT,
  medicalHistory TEXT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  doctorAddress VARCHAR(42),
  patientAddress VARCHAR(42),
  timestamp BIGINT,
  duration INT,
  symptomDescription TEXT,
  status VARCHAR(20),
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (doctorAddress) REFERENCES doctors(address),
  FOREIGN KEY (patientAddress) REFERENCES patients(address)
);

-- prescriptions table
CREATE TABLE IF NOT EXISTS prescriptions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  appointmentId INT,
  doctorAddress VARCHAR(42),
  patientAddress VARCHAR(42),
  medicationDetails TEXT,
  dosage VARCHAR(100),
  frequency VARCHAR(100),
  duration VARCHAR(100),
  additionalNotes TEXT,
  expiryDate TIMESTAMP,
  signature TEXT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointmentId) REFERENCES appointments(id),
  FOREIGN KEY (doctorAddress) REFERENCES doctors(address),
  FOREIGN KEY (patientAddress) REFERENCES patients(address)
); 