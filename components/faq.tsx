"use client"

import { Plus, Minus } from "lucide-react"
import { useState } from "react"

export default function FAQ() {
  const [openId, setOpenId] = useState<number | null>(0)

  const faqs = [
    {
      id: 0,
      question: "What image formats does NanoBanana support?",
      answer:
        "We support all major image formats including PNG, JPG, WebP, JPEG, and GIF. Files up to 10MB can be processed.",
    },
    {
      id: 1,
      question: "How long does image processing take?",
      answer:
        "Most images are processed in under 1 second. Processing time depends on image size and complexity, but typically ranges from 0.2 to 3 seconds.",
    },
    {
      id: 2,
      question: "Is my data secure and private?",
      answer:
        "Absolutely. All images are processed with enterprise-grade encryption and are automatically deleted after processing. We never store or share your data.",
    },
    {
      id: 3,
      question: "Can I use NanoBanana for commercial purposes?",
      answer:
        "Yes, commercial use is fully supported with our Pro and Enterprise plans. Images processed are yours to use freely.",
    },
    {
      id: 4,
      question: "What is the pricing model?",
      answer:
        "We offer flexible pricing: Free plan (5 images/month), Pro ($29/month, unlimited), and Enterprise (custom). No credit card required for free tier.",
    },
    {
      id: 5,
      question: "Do you offer API access?",
      answer:
        "Yes! We provide a powerful REST API and SDKs for Python, Node.js, and Go. Perfect for integrating into your applications.",
    },
  ]

  return (
    <section id="faq" className="py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4 text-center">Frequently Asked Questions</h2>
        <p className="text-center text-muted-foreground mb-12">Everything you need to know about NanoBanana</p>

        <div className="space-y-3">
          {faqs.map((faq) => (
            <div
              key={faq.id}
              className="border border-border rounded-lg overflow-hidden hover:border-primary/50 transition-colors"
            >
              <button
                onClick={() => setOpenId(openId === faq.id ? null : faq.id)}
                className="w-full px-6 py-4 flex items-center justify-between hover:bg-muted/50 transition-colors"
              >
                <span className="font-semibold text-foreground text-left">{faq.question}</span>
                <div className="text-primary">{openId === faq.id ? <Minus size={20} /> : <Plus size={20} />}</div>
              </button>

              {openId === faq.id && (
                <div className="px-6 py-4 bg-muted/30 border-t border-border">
                  <p className="text-muted-foreground">{faq.answer}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
