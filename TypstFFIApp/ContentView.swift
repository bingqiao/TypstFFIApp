import SwiftUI

struct ContentView: View {
    @State private var typstInput: String = """
    #set page(width: 200pt, height: 200pt)
    Hello, *Typst* world!
    """
    @State private var statusMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Typst to PDF Converter")
                .font(.title)
                .padding()

            TextEditor(text: $typstInput)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 300)
                .border(Color.gray, width: 1)
                .padding()

            Button(action: compileAndSavePDF) {
                Text("Compile to PDF")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Text(statusMessage)
                .foregroundColor(statusMessage.contains("Error") ? .red : .green)
                .padding()
        }
        .padding()
    }

    func compileAndSavePDF() {
        // Convert Swift string to C string
        guard let cInput = typstInput.cString(using: .utf8) else {
            statusMessage = "Error: Failed to convert input to C string"
            return
        }

        // Call the Rust function
        var outputLen: UInt = 0
        let pdfPtr = compile_typst(cInput, &outputLen)

        // Check for null pointer
        guard pdfPtr != nil else {
            statusMessage = "Error: Compilation failed"
            return
        }

        // Convert the output to a Data object
        let pdfData = Data(bytes: pdfPtr!, count: Int(outputLen))

        // Free the Rust-allocated buffer
        free_typst_buffer(pdfPtr)

        // Show a save panel to let the user choose where to save the PDF
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = "output.pdf"
        savePanel.canCreateDirectories = true

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try pdfData.write(to: url)
                    statusMessage = "Success: PDF saved to \(url.path)"
                } catch {
                    statusMessage = "Error: Failed to save PDF - \(error.localizedDescription)"
                }
            } else {
                statusMessage = "Error: Save operation cancelled"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
