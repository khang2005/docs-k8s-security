# Deployment Architecture

## K3s Node Structure

The system uses a single node K3s cluster running on the gateway device.

```
K3s Node (Raspberry Pi)
├── mqtt-pod
├── ingest-api-pod
├── database-pod
└── dashboard-pod
```

---

## Service Responsibilities

- **mqtt-pod**  
  handles incoming sensor messages  

- **ingest-api-pod**  
  processes and validates data before storage  

- **database-pod**  
  stores structured sensor data  

- **dashboard-pod**  
  serves the web interface  

---

## Networking

- services communicate internally using cluster networking  
- external access provided through local network or secure tunnel  
- gateway acts as entry point for all system interactions  
