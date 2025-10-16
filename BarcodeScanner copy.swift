
import SwiftUI

struct ContentView: View {
    // MARK: - State & Objects
    @StateObject private var scanner = BarcodeScanner()
    @State private var isScanning = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: Camera preview (only displayed when a session exists)
                if let session = scanner.captureSession, isScanning {
                    CameraPreview(session: session)
                        .aspectRatio(3/4, contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    // Placeholder when the preview is not active
                    Color.secondary.opacity(0.2)
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay(
                            Text("Camera preview will appear here")
                                .foregroundColor(.secondary)
                        )
                }
                
                // MARK: Scan result
                if let code = scanner.detectedBarcode {
                    VStack {
                        Text("Scanned value:")
                            .font(.headline)
                        Text(code)
                            .font(.title2)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                // MARK: Controls
                HStack(spacing: 30) {
                    Button(action: startOrResumeScanning) {
                        Label(isScanning ? "Pause" : "Start Scan", systemImage: isScanning ? "pause.circle" : "camera.viewfinder")
                            .font(.title2)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(role: .destructive, action: resetScanner) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            .navigationTitle("Barcode Scanner")
            .alert(isPresented: $scanner.showAccessDeniedAlert) {
                Alert(
                    title: Text("Camera Access Required"),
                    message: Text(scanner.cameraAccessDeniedMessage),
                    primaryButton: .default(Text("Open Settings")) {
                        // Open Settings so the user can grant permission again
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                // Kick‑off permission request as soon as the view appears
                scanner.startScanning()
            }
            .onDisappear {
                scanner.stopScanning()
            }
        }
    }
    
    // MARK: - Helper actions
    
    private func startOrResumeScanning() {
        if isScanning {
            // Pause / stop the running session
            scanner.stopScanning()
        } else {
            // (Re)start – will also request permission if needed
            scanner.startScanning()
        }
        isScanning.toggle()
    }
    
    private func resetScanner() {
        // Clear previous results and restart a fresh session
        scanner.detectedBarcode = nil
        scanner.stopScanning()
        isScanning = false
        scanner.startScanning()
        isScanning = true
    }
}
