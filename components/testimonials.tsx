import { Star } from "lucide-react"

export default function Testimonials() {
  const testimonials = [
    {
      id: 1,
      name: "Sarah Chen",
      role: "E-commerce Manager",
      content:
        "NanoBanana has revolutionized our product photography workflow. The AI enhancement is incredibly fast and produces professional results.",
      rating: 5,
      avatar: "👩‍💼",
    },
    {
      id: 2,
      name: "Michael Rodriguez",
      role: "Real Estate Agent",
      content:
        "The image quality improvement is remarkable. Our property listings now look premium without expensive professional photographers.",
      rating: 5,
      avatar: "👨‍💼",
    },
    {
      id: 3,
      name: "Emma Thompson",
      role: "Content Creator",
      content:
        "Perfect tool for social media. The AI understands context and enhances images while keeping them looking natural.",
      rating: 5,
      avatar: "👩‍🎨",
    },
    {
      id: 4,
      name: "David Kumar",
      role: "Marketing Director",
      content:
        "The efficiency gains are substantial. We process 10x more images per day while maintaining quality standards.",
      rating: 5,
      avatar: "👨‍💻",
    },
  ]

  return (
    <section id="testimonials" className="py-20 px-4 sm:px-6 lg:px-8 bg-muted/30">
      <div className="max-w-7xl mx-auto">
        <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4 text-center">Loved by Users Worldwide</h2>
        <p className="text-center text-muted-foreground mb-16">
          Join thousands of professionals who trust NanoBanana for their image processing needs
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {testimonials.map((testimonial) => (
            <div
              key={testimonial.id}
              className="p-6 bg-card rounded-xl border border-border hover:border-primary/50 transition-all"
            >
              <div className="flex items-center gap-4 mb-4">
                <span className="text-3xl">{testimonial.avatar}</span>
                <div>
                  <p className="font-semibold text-foreground">{testimonial.name}</p>
                  <p className="text-sm text-muted-foreground">{testimonial.role}</p>
                </div>
              </div>

              <div className="flex gap-1 mb-4">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star key={i} size={16} className="fill-primary text-primary" />
                ))}
              </div>

              <p className="text-muted-foreground text-sm">"{testimonial.content}"</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
