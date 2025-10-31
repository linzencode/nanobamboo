export default function Footer() {
  return (
    <footer className="bg-foreground text-background py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-foreground font-bold">
                🍌
              </div>
              <span className="text-lg font-bold">NanoBanana</span>
            </div>
            <p className="text-background/70 text-sm">
              Advanced AI-powered image processing for professionals worldwide.
            </p>
          </div>

          <div>
            <h4 className="font-semibold mb-4">Product</h4>
            <ul className="space-y-2 text-sm text-background/70">
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Features
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Pricing
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  API Docs
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Blog
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h4 className="font-semibold mb-4">Company</h4>
            <ul className="space-y-2 text-sm text-background/70">
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  About
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Careers
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Contact
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Press
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h4 className="font-semibold mb-4">Legal</h4>
            <ul className="space-y-2 text-sm text-background/70">
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Privacy
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Terms
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Security
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-background transition-colors">
                  Cookies
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t border-background/20 pt-8">
          <div className="flex flex-col md:flex-row items-center justify-between">
            <p className="text-sm text-background/70">© 2025 NanoBanana. All rights reserved.</p>
            <div className="flex gap-6 mt-4 md:mt-0">
              <a href="#" className="text-background/70 hover:text-background transition-colors">
                Twitter
              </a>
              <a href="#" className="text-background/70 hover:text-background transition-colors">
                GitHub
              </a>
              <a href="#" className="text-background/70 hover:text-background transition-colors">
                LinkedIn
              </a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}
