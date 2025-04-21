const UserManagement = artifacts.require("UserManagement");
const Authentication = artifacts.require("Authentication");
const Consultation = artifacts.require("Consultation");
const Prescription = artifacts.require("Prescription");

module.exports = async function(deployer) {
  // Deploy UserManagement first
  await deployer.deploy(UserManagement);
  const userManagementInstance = await UserManagement.deployed();
  
  // Deploy Authentication with UserManagement address
  await deployer.deploy(Authentication, userManagementInstance.address);
  
  // Deploy Consultation with UserManagement address
  await deployer.deploy(Consultation, userManagementInstance.address);
  const consultationInstance = await Consultation.deployed();
  
  // Deploy Prescription with UserManagement and Consultation addresses
  await deployer.deploy(
    Prescription, 
    userManagementInstance.address, 
    consultationInstance.address
  );
};