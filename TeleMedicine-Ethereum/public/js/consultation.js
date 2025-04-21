

console.log("🧪 consultation.js is loaded!");

// Handle appointment submission
async function handleAppointmentSubmission(event) {
  event.preventDefault();

  const doctorAddress = document.getElementById('doctor-select').value;
  const appointmentDate = document.getElementById('appointment-date').value;
  const appointmentTime = document.getElementById('appointment-time').value;
  const duration = document.getElementById('appointment-duration').value;
  const symptoms = document.getElementById('symptoms').value;

  if (!doctorAddress || !appointmentDate || !appointmentTime || !duration || !symptoms) {
    alert('Please fill all fields');
    return;
  }

  const dateTime = new Date(`${appointmentDate}T${appointmentTime}`);
  const timestamp = Math.floor(dateTime.getTime() / 1000);

  try {
    const response = await fetch("http://localhost:5000/api/appointments", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        doctorAddress,
        patientAddress: currentAccount,
        timestamp,
        duration,
        symptomDescription: symptoms
      })
    });

    if (response.ok) {
      alert("Appointment scheduled successfully!");
      await loadPatientAppointments();
      document.getElementById('appointment-form').reset();
      document.querySelector('.sidebar-menu a[data-tab="appointments"]').click();
    } else {
      const err = await response.json();
      throw new Error(err.error);
    }
  } catch (error) {
    console.error("Error scheduling appointment:", error);
    alert("Failed to schedule appointment");
  }
}

async function loadPatientAppointments() {
  try {
    const res = await fetch(`http://localhost:5000/api/appointments/patient/${currentAccount}`);
    const appointments = await res.json();
    loadPatientAppointmentsTableFromSQL(appointments);
  } catch (err) {
    console.error("Error loading patient appointments:", err);
  }
}

async function loadDoctorAppointments() {
  try {
    console.log("📡 Fetching appointments for doctor:", currentAccount); // Log 1

    const res = await fetch(`http://localhost:5000/api/appointments/doctor/${currentAccount}`);
    const appointments = await res.json();

    console.log("📋 Appointments received from API:", appointments); // Log 2

    loadDoctorAppointmentsTableFromSQL(appointments);
  } catch (err) {
    console.error("❌ Error loading doctor appointments:", err);
  }
}


function loadPatientAppointmentsTableFromSQL(data) {
  const tableBody = document.querySelector("#appointments-table tbody");
  if (!tableBody) return;
  tableBody.innerHTML = "";

  data.forEach(appointment => {
    const date = new Date(appointment.timestamp * 1000).toLocaleString();
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${appointment.id}</td>
      <td>${appointment.doctorAddress}</td>
      <td>${date}</td>
      <td>${appointment.duration} min</td>
      <td>${appointment.status}</td>
      <td></td>`;
    tableBody.appendChild(row);
  });
}

function loadDoctorAppointmentsTableFromSQL(data) {
  const tableBody = document.querySelector("#appointments-table tbody");
  if (!tableBody) return;
  tableBody.innerHTML = "";

  data.forEach(appointment => {
    const date = new Date(appointment.timestamp * 1000).toLocaleString();
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${appointment.id}</td>
      <td>${appointment.patientAddress}</td>
      <td>${date}</td>
      <td>${appointment.duration} min</td>
      <td>${appointment.symptomDescription}</td>
      <td>${appointment.status}</td>
      <td></td>`;
    tableBody.appendChild(row);
  });
}

function loadDoctorListForAppointment() {
    const doctorSelect = document.getElementById('doctor-select');
    doctorSelect.innerHTML = '<option value="">-- Select a Doctor --</option>';
  
    fetch("http://localhost:5000/api/doctors")
      .then(res => res.json())
      .then(doctors => {
        doctors.forEach(doc => {
          const option = document.createElement("option");
          option.value = doc.address;
          option.textContent = `Dr. ${doc.name} - ${doc.specialization}`;
          doctorSelect.appendChild(option);
        });
      })
      .catch(err => {
        console.error("Failed to load doctors:", err);
      });
  }
  
// Load correct data depending on the current dashboard
window.addEventListener('load', () => {
  const waitForAccount = setInterval(() => {
    if (currentAccount) {
      clearInterval(waitForAccount);
      console.log("✅ consultation.js got currentAccount:", currentAccount);

      const path = window.location.pathname;

      if (document.getElementById('appointment-form')) {
        document.getElementById('appointment-form')
          .addEventListener('submit', handleAppointmentSubmission);
        loadDoctorListForAppointment();
      }

      if (path.includes("doctor-dashboard.html")) {
        loadDoctorAppointments();
      }

      if (path.includes("patient-dashboard.html")) {
        loadPatientAppointments();
      }
    } else {
      console.log("⏳ Waiting for currentAccount...");
    }
  }, 200); // check every 200ms
});
