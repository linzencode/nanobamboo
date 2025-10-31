export default function Hero() {
  return (
    <section className="py-20 md:py-32 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
      <div className="max-w-4xl mx-auto text-center">
        <h1 className="text-4xl md:text-6xl font-bold text-foreground mb-6 text-balance">
          Transform Your Images with <span className="text-primary">AI Intelligence</span>
        </h1>
        <p className="text-lg md:text-xl text-muted-foreground mb-8 text-balance">
          Professional-grade image processing powered by cutting-edge AI. Upload, analyze, and enhance your images in
          seconds.
        </p>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <button className="px-8 py-3 bg-primary text-primary-foreground rounded-full font-semibold hover:opacity-90 transition-opacity">
            Start Processing
          </button>
          <button className="px-8 py-3 border-2 border-primary text-primary rounded-full font-semibold hover:bg-primary/5 transition-colors">
            View Demo
          </button>
        </div>
      </div>

      {/* Decorative bamboo elements */}
      <div className="absolute left-0 top-20 opacity-10 w-24 h-48 bg-gradient-to-r from-secondary to-transparent rounded-full blur-3xl" />
      <div className="absolute right-0 bottom-20 opacity-10 w-24 h-48 bg-gradient-to-l from-secondary to-transparent rounded-full blur-3xl" />
    </section>
  )
}
