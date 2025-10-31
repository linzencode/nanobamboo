"use client"
import Header from "@/components/header"
import Hero from "@/components/hero"
import ImageUploader from "@/components/image-uploader"
import CaseShowcase from "@/components/case-showcase"
import Testimonials from "@/components/testimonials"
import FAQ from "@/components/faq"
import Footer from "@/components/footer"

export default function Home() {
  return (
    <div className="min-h-screen bg-background">
      <Header />
      <Hero />
      <ImageUploader />
      <CaseShowcase />
      <Testimonials />
      <FAQ />
      <Footer />
    </div>
  )
}
