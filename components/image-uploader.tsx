"use client"

import type React from "react"

import { Upload } from "lucide-react"
import { useState, useRef } from "react"

export default function ImageUploader() {
  const [uploadedImage, setUploadedImage] = useState<string | null>(null)
  const [isDragging, setIsDragging] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleImageUpload = (file: File) => {
    const reader = new FileReader()
    reader.onload = (e) => {
      setUploadedImage(e.target?.result as string)
    }
    reader.readAsDataURL(file)
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = () => {
    setIsDragging(false)
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
    const files = e.dataTransfer.files
    if (files[0]) {
      handleImageUpload(files[0])
    }
  }

  return (
    <section id="features" className="py-20 px-4 sm:px-6 lg:px-8 bg-muted/30">
      <div className="max-w-4xl mx-auto">
        <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4 text-center">Upload Your Image</h2>
        <p className="text-center text-muted-foreground mb-12">
          Drag and drop your image or click to browse from your device
        </p>

        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          className={`border-2 border-dashed rounded-2xl p-12 text-center transition-all cursor-pointer ${
            isDragging ? "border-primary bg-primary/5" : "border-border hover:border-primary/50"
          }`}
        >
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={(e) => e.target.files?.[0] && handleImageUpload(e.target.files[0])}
          />

          <button onClick={() => fileInputRef.current?.click()} className="flex flex-col items-center gap-4 w-full">
            {uploadedImage ? (
              <div className="w-full">
                <img
                  src={uploadedImage || "/placeholder.svg"}
                  alt="Uploaded"
                  className="max-w-full max-h-96 mx-auto rounded-lg"
                />
                <button
                  onClick={(e) => {
                    e.preventDefault()
                    setUploadedImage(null)
                  }}
                  className="mt-4 px-6 py-2 bg-secondary text-secondary-foreground rounded-full font-semibold hover:opacity-90 transition-opacity"
                >
                  Upload Another
                </button>
              </div>
            ) : (
              <>
                <Upload size={48} className="text-primary" />
                <div>
                  <p className="text-lg font-semibold text-foreground">Click or drag to upload</p>
                  <p className="text-sm text-muted-foreground mt-2">PNG, JPG, WebP up to 10MB</p>
                </div>
              </>
            )}
          </button>
        </div>

        {uploadedImage && (
          <div className="mt-12 p-6 bg-card rounded-2xl border border-border">
            <h3 className="text-lg font-semibold text-foreground mb-4">Processing Results</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="p-4 bg-muted rounded-lg">
                <p className="text-sm text-muted-foreground mb-2">Image Quality</p>
                <p className="text-2xl font-bold text-primary">98%</p>
              </div>
              <div className="p-4 bg-muted rounded-lg">
                <p className="text-sm text-muted-foreground mb-2">Processing Time</p>
                <p className="text-2xl font-bold text-primary">0.3s</p>
              </div>
              <div className="p-4 bg-muted rounded-lg">
                <p className="text-sm text-muted-foreground mb-2">AI Confidence</p>
                <p className="text-2xl font-bold text-primary">99.7%</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </section>
  )
}
