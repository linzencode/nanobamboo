"use client"

import { Menu, X } from "lucide-react"
import { useState } from "react"

export default function Header() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  return (
    <header className="sticky top-0 z-50 bg-background/80 backdrop-blur-md border-b border-border">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-primary-foreground font-bold">
              🍌
            </div>
            <span className="text-xl font-bold text-foreground">NanoBanana</span>
          </div>

          <nav className="hidden md:flex items-center gap-8">
            <a href="#features" className="text-foreground hover:text-primary transition-colors">
              Features
            </a>
            <a href="#showcase" className="text-foreground hover:text-primary transition-colors">
              Showcase
            </a>
            <a href="#testimonials" className="text-foreground hover:text-primary transition-colors">
              Reviews
            </a>
            <a href="#faq" className="text-foreground hover:text-primary transition-colors">
              FAQ
            </a>
          </nav>

          <button className="hidden md:block px-6 py-2 bg-primary text-primary-foreground rounded-full font-semibold hover:opacity-90 transition-opacity">
            Get Started
          </button>

          <button className="md:hidden" onClick={() => setMobileMenuOpen(!mobileMenuOpen)}>
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>

        {mobileMenuOpen && (
          <nav className="md:hidden pb-4 flex flex-col gap-4">
            <a href="#features" className="text-foreground hover:text-primary">
              Features
            </a>
            <a href="#showcase" className="text-foreground hover:text-primary">
              Showcase
            </a>
            <a href="#testimonials" className="text-foreground hover:text-primary">
              Reviews
            </a>
            <a href="#faq" className="text-foreground hover:text-primary">
              FAQ
            </a>
            <button className="w-full px-6 py-2 bg-primary text-primary-foreground rounded-full font-semibold">
              Get Started
            </button>
          </nav>
        )}
      </div>
    </header>
  )
}
