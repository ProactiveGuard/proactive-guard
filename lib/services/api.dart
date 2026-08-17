import 'dart:convert'; 
import 'package:http/http.dart' as http; 
class ApiService { 
// Hackathon Secret: 10.0.2.2 is how the Android Emulator talks to your laptop's 

static const String backendUrl = "http://10.0.2.2:8000/api/v1/telemetry"; 
static Future<void> sendSOSAlert() async { 
print("Preparing to send SOS to Backend..."); 
try { 
// 1. Create fake dangerous sensor data (Member 5's logic will read this!) 
Map<String, dynamic> fakeSensorData = { 
"user_id": "U-139", 
"latitude": 28.6139, 
"longitude": 77.2090, 
"motion_score": 9.5, // High motion (running) 
"audio_score": 10.0  // High audio (screaming) 
}; 
// 2. Send the data over the internet using a POST request 
var response = await http.post( 
Uri.parse(backendUrl), 
headers: {"Content-Type": "application/json"}, 
body: jsonEncode(fakeSensorData), 
); 
// 3. Read the backend's reply 
if (response.statusCode == 200) { 
print("SUCCESS! Backend replied: ${response.body}"); 
} else { 
print("Error sending alert: ${response.statusCode}"); 
} 
} catch (e) { 
print("Failed to connect to the backend. Is the server running? Error: $e"); 
} 
} 
}