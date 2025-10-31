export default function CaseShowcase() {
  const cases = [
    {
      id: 1,
      title: "E-commerce Product Enhancement",
      description: "Automatically enhance and optimize product images for online stores",
      image: "/ecommerce-product-showcase-with-enhanced-quality.jpg",
      category: "Retail",
    },
    {
      id: 2,
      title: "Real Estate Photography",
      description: "Professional photo enhancement for property listings and marketing",
      image: "/modern-real-estate-property-interior-design.jpg",
      category: "Real Estate",
    },
    {
      id: 3,
      title: "Social Media Optimization",
      description: "Perfect your images for maximum engagement across platforms",
      image: "/vibrant-social-media-content-creation-setup.jpg",
      category: "Marketing",
    },
    {
      id: 4,
      title: "Medical Imaging Analysis",
      description: "AI-powered medical image analysis and diagnostics support",
      image: "/medical-imaging-healthcare-technology.jpg",
      category: "Healthcare",
    },
  ]

  return (
    <section id="showcase" className="py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4 text-center">Real-World Applications</h2>
        <p className="text-center text-muted-foreground mb-16">
          See how businesses use NanoBanana to streamline their workflows
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {cases.map((caseItem) => (
            <div
              key={caseItem.id}
              className="group overflow-hidden rounded-2xl border border-border hover:border-primary/50 transition-all duration-300 hover:shadow-lg"
            >
              <div className="relative overflow-hidden h-64 bg-muted">
                <img
                  src={caseItem.image || "/placeholder.svg"}
                  alt={caseItem.title}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
              </div>

              <div className="p-6">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-xs font-semibold text-primary bg-primary/10 px-3 py-1 rounded-full">
                    {caseItem.category}
                  </span>
                </div>
                <h3 className="text-xl font-semibold text-foreground mb-2">{caseItem.title}</h3>
                <p className="text-muted-foreground mb-4">{caseItem.description}</p>
                <button className="text-primary font-semibold hover:gap-2 flex items-center gap-1 transition-all">
                  Learn More →
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
