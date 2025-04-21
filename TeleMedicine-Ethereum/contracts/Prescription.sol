// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserManagement.sol";
import "./Consultation.sol";

contract Prescription {
    // Structs
    struct PrescriptionData {
        uint256 id;
        uint256 appointmentId;
        address patient;
        address doctor;
        string medicationDetails;
        string dosage;
        string frequency;
        string duration;
        string additionalNotes;
        uint256 issueDate;
        uint256 expiryDate;
        bytes signature;
        bool exists;
    }
    
    // State variables
    UserManagement private userManagement;
    Consultation private consultation;
    uint256 private prescriptionCounter;
    
    // Mappings
    mapping(uint256 => PrescriptionData) public prescriptions;
    mapping(address => uint256[]) public doctorPrescriptions;
    mapping(address => uint256[]) public patientPrescriptions;
    
    // Events
    event PrescriptionIssued(
        uint256 indexed prescriptionId,
        uint256 indexed appointmentId,
        address indexed patient,
        address doctor
    );
    
    // Modifiers
    modifier onlyDoctor() {
        require(userManagement.isDoctor(msg.sender), "Only verified doctors can call this function");
        _;
    }
    
    modifier onlyParticipant(uint256 _prescriptionId) {
        require(
            prescriptions[_prescriptionId].patient == msg.sender || 
            prescriptions[_prescriptionId].doctor == msg.sender,
            "Only participants can access this prescription"
        );
        _;
    }
    
    constructor(address _userManagementAddress, address _consultationAddress) {
        userManagement = UserManagement(_userManagementAddress);
        consultation = Consultation(_consultationAddress);
        prescriptionCounter = 0;
    }
    
    // Issue a new prescription (doctor only)
    function issuePrescription(
        uint256 _appointmentId,
        string memory _medicationDetails,
        string memory _dosage,
        string memory _frequency,
        string memory _duration,
        string memory _additionalNotes,
        uint256 _expiryDate,
        bytes memory _signature
    ) external onlyDoctor returns (uint256) {
        // Get appointment details
        (address patient, address doctor, , , , Consultation.AppointmentStatus status) = 
            consultation.getAppointmentDetails(_appointmentId);
        
        require(doctor == msg.sender, "Only the doctor who conducted the appointment can issue a prescription");
        require(status == Consultation.AppointmentStatus.Completed, "Appointment must be completed to issue a prescription");
        require(_expiryDate > block.timestamp, "Expiry date must be in the future");
        
        uint256 prescriptionId = prescriptionCounter++;
        
        prescriptions[prescriptionId] = PrescriptionData({
            id: prescriptionId,
            appointmentId: _appointmentId,
            patient: patient,
            doctor: msg.sender,
            medicationDetails: _medicationDetails,
            dosage: _dosage,
            frequency: _frequency,
            duration: _duration,
            additionalNotes: _additionalNotes,
            issueDate: block.timestamp,
            expiryDate: _expiryDate,
            signature: _signature,
            exists: true
        });
        
        doctorPrescriptions[msg.sender].push(prescriptionId);
        patientPrescriptions[patient].push(prescriptionId);
        
        emit PrescriptionIssued(prescriptionId, _appointmentId, patient, msg.sender);
        
        return prescriptionId;
    }
    
    // Verify prescription signature
    function verifyPrescription(uint256 _prescriptionId, bytes memory _signature) external view returns (bool) {
        PrescriptionData storage prescription = prescriptions[_prescriptionId];
        require(prescription.exists, "Prescription does not exist");
        
        // Compare the signatures
        bytes32 signatureHash = keccak256(prescription.signature);
        bytes32 providedSignatureHash = keccak256(_signature);
        
        return signatureHash == providedSignatureHash;
    }
    
    // Get prescription details
    function getPrescriptionDetails(uint256 _prescriptionId) 
        external 
        view 
        onlyParticipant(_prescriptionId) 
        returns (
            uint256 appointmentId,
            address patient,
            address doctor,
            string memory medicationDetails,
            string memory dosage,
            string memory frequency,
            string memory duration,
            string memory additionalNotes,
            uint256 issueDate,
            uint256 expiryDate,
            bytes memory signature
        ) 
    {
        PrescriptionData storage prescription = prescriptions[_prescriptionId];
        require(prescription.exists, "Prescription does not exist");
        
        return (
            prescription.appointmentId,
            prescription.patient,
            prescription.doctor,
            prescription.medicationDetails,
            prescription.dosage,
            prescription.frequency,
            prescription.duration,
            prescription.additionalNotes,
            prescription.issueDate,
            prescription.expiryDate,
            prescription.signature
        );
    }
    
    // Get doctor's issued prescriptions
    function getDoctorPrescriptions() external view onlyDoctor returns (uint256[] memory) {
        return doctorPrescriptions[msg.sender];
    }
    
    // Get patient's prescriptions
    function getPatientPrescriptions() external view returns (uint256[] memory) {
        require(userManagement.isPatient(msg.sender), "Only registered patients can call this function");
        return patientPrescriptions[msg.sender];
    }
    
    // Check if a prescription is valid (not expired)
    function isPrescriptionValid(uint256 _prescriptionId) external view returns (bool) {
        PrescriptionData storage prescription = prescriptions[_prescriptionId];
        require(prescription.exists, "Prescription does not exist");
        
        return block.timestamp <= prescription.expiryDate;
    }
}