"""
Generate precision SVG logo files for BANDHU - AI Cognitive Care Companion
"""
import os

LOGO_DIR = r"c:\Users\gmune\OneDrive\Desktop\DEMO\assets\logo"
os.makedirs(LOGO_DIR, exist_ok=True)

# 1. Standalone Emblem SVG
emblem_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="100%" height="100%">
  <defs>
    <!-- Gradients for subtle depth -->
    <linearGradient id="bandhuTealGrad" x1="0%" y1="100%" x2="50%" y2="0%">
      <stop offset="0%" stop-color="#0B3C49" />
      <stop offset="100%" stop-color="#145E6F" />
    </linearGradient>

    <linearGradient id="bandhuSageGrad" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#4E7865" />
      <stop offset="60%" stop-color="#6F9D87" />
      <stop offset="100%" stop-color="#8DB69F" />
    </linearGradient>

    <linearGradient id="bandhuOrbitGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#8DB69F" stop-opacity="0.2" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.8" />
      <stop offset="100%" stop-color="#145E6F" stop-opacity="0.9" />
    </linearGradient>

    <radialGradient id="nodeGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#A4E2C6" stop-opacity="1" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.4" />
      <stop offset="100%" stop-color="#5E8C76" stop-opacity="0" />
    </radialGradient>

    <filter id="softGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="3" result="blur" />
      <feComposite in="SourceGraphic" in2="blur" operator="over" />
    </filter>
  </defs>

  <!-- BACKGROUND: Transparent by default for versatility -->

  <!-- EMBLEM GROUP (Centered at 250, 240) -->
  <g id="bandhu-emblem" transform="translate(0, -10)">
    
    <!-- Outer Neural Orbit Arc (Memory / AI Technology) -->
    <path d="M 125,275 C 95,220 110,135 180,85 C 240,40 330,48 385,100 C 428,140 435,210 395,275 C 360,332 290,395 250,420" 
          fill="none" 
          stroke="url(#bandhuOrbitGrad)" 
          stroke-width="3" 
          stroke-linecap="round" 
          stroke-dasharray="320 8 4 8" />

    <!-- Neural Orbit Node (Interactive AI Dot) -->
    <circle cx="398" cy="120" r="14" fill="url(#nodeGlow)" />
    <circle cx="398" cy="120" r="6" fill="#145E6F" />
    <circle cx="398" cy="120" r="3.5" fill="#C8EADB" />

    <!-- Secondary small neural sync node -->
    <circle cx="118" cy="245" r="4" fill="#6F9D87" opacity="0.8" />
    <circle cx="118" cy="245" r="2" fill="#FAF8F5" />

    <!-- MAIN HEART / EMBRACE SHAPE (Continuous Harmonious Form) -->
    <!-- Right Embrace Arm: Companion (Sage Green Ribbon) -->
    <path d="M 250,410 
             C 285,385 355,330 380,265 
             C 405,200 390,130 340,95 
             C 295,65 245,95 245,135 
             C 245,175 285,195 320,185 
             C 345,178 358,155 350,135 
             C 335,100 290,85 255,115
             C 280,105 315,110 330,135
             C 340,152 328,172 305,176
             C 275,182 235,160 235,125
             C 235,80 290,45 348,78
             C 408,112 425,190 395,260
             C 368,322 300,378 250,410 Z" 
          fill="url(#bandhuSageGrad)" />

    <!-- Left Embrace Arm: Deep Foundation / Shielding Embrace (Teal Ribbon) -->
    <path d="M 250,410 
             C 205,378 135,320 108,255 
             C 80,188 95,112 158,78 
             C 200,55 242,75 250,115 
             C 242,88 208,72 170,88 
             C 120,110 102,175 125,238 
             C 148,298 210,355 250,388 
             C 256,383 252,408 250,410 Z" 
          fill="url(#bandhuTealGrad)" />

    <!-- Smooth base join heart apex -->
    <path d="M 235,396 C 245,412 255,412 265,396 C 255,404 245,404 235,396 Z" fill="#0B3C49" />

    <!-- MEMORY & GROWTH BOTANICAL LEAF (Seamlessly integrated on left ribbon) -->
    <g id="growth-leaf" transform="translate(112, 140) rotate(-22)">
      <!-- Leaf 1 (Primary) -->
      <path d="M 0,40 C -15,25 -25,-5 5,-30 C 20,-5 20,20 0,40 Z" fill="#6F9D87" />
      <path d="M 0,38 C 2,15 4,-5 5,-28" stroke="#FAF8F5" stroke-width="1.8" stroke-linecap="round" opacity="0.7" fill="none" />
      <!-- Leaf 2 (Budding subtle secondary) -->
      <path d="M -8,18 C -22,12 -28,-2 -12,-16 C -2,0 0,10 -8,18 Z" fill="#8DB69F" opacity="0.9" />
    </g>

    <!-- CENTRAL FIGURES: Elderly Person & AI Companion in Harmonious Minimalist Silhouette -->
    
    <!-- AI Caring Companion Figure (Gentle, supportive, upright) -->
    <g id="companion-figure">
      <!-- Head -->
      <circle cx="295" cy="195" r="23" fill="#4E7865" />
      <!-- Minimalist Supportive Body & Arm extending around elder -->
      <path d="M 295,225 
               C 315,228 335,245 338,275 
               L 338,325 
               C 325,330 305,332 290,320 
               L 290,265 
               C 278,262 258,266 242,282 
               C 236,288 228,284 230,276 
               C 236,252 262,235 295,225 Z" 
            fill="#5E8C76" />
    </g>

    <!-- Elderly Figure (Dignified curved silhouette, recognized gentle posture) -->
    <g id="elderly-figure">
      <!-- Head / Face Silhouette (Warm Deep Teal) -->
      <circle cx="218" cy="225" r="21" fill="#0B3C49" />
      <!-- Distinctive Soft Silver/Sage Hair Shape (Recognizable elder trait, clean minimal geometry) -->
      <path d="M 200,222 
               C 198,202 214,194 230,198 
               C 240,201 245,210 244,218 
               C 238,212 230,208 218,210 
               C 208,212 203,218 200,222 Z" 
            fill="#D5E2DA" />
      <!-- Elegant minimal hair bun contour -->
      <circle cx="199" cy="216" r="7.5" fill="#D5E2DA" />
      
      <!-- Gentle Curved Body (Resting peacefully in embrace) -->
      <path d="M 226,250 
               C 245,255 252,275 252,310 
               C 242,328 220,335 198,328 
               C 188,320 182,300 185,280 
               C 188,260 205,248 226,250 Z" 
            fill="#0F4C5C" />
    </g>

    <!-- Warm Loving Union Accent: Subtle inner connection curve -->
    <path d="M 225,280 C 235,270 252,270 262,282" 
          stroke="#FAF8F5" 
          stroke-width="3" 
          stroke-linecap="round" 
          opacity="0.4" 
          fill="none" />

  </g>
</svg>'''

with open(os.path.join(LOGO_DIR, "bandhu-emblem.svg"), "w", encoding="utf-8") as f:
    f.write(emblem_svg.strip())

# 2. Full Stacked Logo (Emblem + "BANDHU" + Tagline)
full_logo_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 680" width="100%" height="100%">
  <defs>
    <linearGradient id="flTealGrad" x1="0%" y1="100%" x2="50%" y2="0%">
      <stop offset="0%" stop-color="#0B3C49" />
      <stop offset="100%" stop-color="#145E6F" />
    </linearGradient>

    <linearGradient id="flSageGrad" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#4E7865" />
      <stop offset="60%" stop-color="#6F9D87" />
      <stop offset="100%" stop-color="#8DB69F" />
    </linearGradient>

    <linearGradient id="flOrbitGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#8DB69F" stop-opacity="0.2" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.8" />
      <stop offset="100%" stop-color="#145E6F" stop-opacity="0.9" />
    </linearGradient>

    <radialGradient id="flNodeGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#A4E2C6" stop-opacity="1" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.4" />
      <stop offset="100%" stop-color="#5E8C76" stop-opacity="0" />
    </radialGradient>
  </defs>

  <!-- EMBLEM SCALED & CENTERED -->
  <g transform="translate(50, 20)">
    <!-- Outer Neural Orbit Arc -->
    <path d="M 125,275 C 95,220 110,135 180,85 C 240,40 330,48 385,100 C 428,140 435,210 395,275 C 360,332 290,395 250,420" 
          fill="none" stroke="url(#flOrbitGrad)" stroke-width="3" stroke-linecap="round" stroke-dasharray="320 8 4 8" />

    <!-- Neural Orbit Node -->
    <circle cx="398" cy="120" r="14" fill="url(#flNodeGlow)" />
    <circle cx="398" cy="120" r="6" fill="#145E6F" />
    <circle cx="398" cy="120" r="3.5" fill="#C8EADB" />

    <circle cx="118" cy="245" r="4" fill="#6F9D87" opacity="0.8" />
    <circle cx="118" cy="245" r="2" fill="#FAF8F5" />

    <!-- Right Embrace Arm (Companion / Sage Green) -->
    <path d="M 250,410 
             C 285,385 355,330 380,265 
             C 405,200 390,130 340,95 
             C 295,65 245,95 245,135 
             C 245,175 285,195 320,185 
             C 345,178 358,155 350,135 
             C 335,100 290,85 255,115
             C 280,105 315,110 330,135
             C 340,152 328,172 305,176
             C 275,182 235,160 235,125
             C 235,80 290,45 348,78
             C 408,112 425,190 395,260
             C 368,322 300,378 250,410 Z" 
          fill="url(#flSageGrad)" />

    <!-- Left Embrace Arm (Teal) -->
    <path d="M 250,410 
             C 205,378 135,320 108,255 
             C 80,188 95,112 158,78 
             C 200,55 242,75 250,115 
             C 242,88 208,72 170,88 
             C 120,110 102,175 125,238 
             C 148,298 210,355 250,388 
             C 256,383 252,408 250,410 Z" 
          fill="url(#flTealGrad)" />

    <path d="M 235,396 C 245,412 255,412 265,396 C 255,404 245,404 235,396 Z" fill="#0B3C49" />

    <!-- Leaf Motif -->
    <g id="growth-leaf-fl" transform="translate(112, 140) rotate(-22)">
      <path d="M 0,40 C -15,25 -25,-5 5,-30 C 20,-5 20,20 0,40 Z" fill="#6F9D87" />
      <path d="M 0,38 C 2,15 4,-5 5,-28" stroke="#FAF8F5" stroke-width="1.8" stroke-linecap="round" opacity="0.7" fill="none" />
      <path d="M -8,18 C -22,12 -28,-2 -12,-16 C -2,0 0,10 -8,18 Z" fill="#8DB69F" opacity="0.9" />
    </g>

    <!-- Companion Silhouette -->
    <circle cx="295" cy="195" r="23" fill="#4E7865" />
    <path d="M 295,225 
             C 315,228 335,245 338,275 
             L 338,325 
             C 325,330 305,332 290,320 
             L 290,265 
             C 278,262 258,266 242,282 
             C 236,288 228,284 230,276 
             C 236,252 262,235 295,225 Z" 
          fill="#5E8C76" />

    <!-- Elder Silhouette -->
    <circle cx="218" cy="225" r="21" fill="#0B3C49" />
    <path d="M 200,222 
             C 198,202 214,194 230,198 
             C 240,201 245,210 244,218 
             C 238,212 230,208 218,210 
             C 208,212 203,218 200,222 Z" 
          fill="#D5E2DA" />
    <circle cx="199" cy="216" r="7.5" fill="#D5E2DA" />
    <path d="M 226,250 
             C 245,255 252,275 252,310 
             C 242,328 220,335 198,328 
             C 188,320 182,300 185,280 
             C 188,260 205,248 226,250 Z" 
          fill="#0F4C5C" />

    <path d="M 225,280 C 235,270 252,270 262,282" stroke="#FAF8F5" stroke-width="3" stroke-linecap="round" opacity="0.4" fill="none" />
  </g>

  <!-- TYPOGRAPHY: BANDHU (Bold Modern Rounded Geometric Sans-Serif) -->
  <g id="brand-typography" transform="translate(0, 475)">
    <!-- Precision SVG Lettering for "BANDHU" (Independence from local fonts) -->
    <!-- B -->
    <path d="M 92,72 L 92,20 C 92,15 96,12 101,12 L 126,12 C 140,12 149,19 149,30 C 149,37 144,43 137,45 C 146,47 152,55 152,64 C 152,76 141,84 126,84 L 101,84 C 96,84 92,80 92,75 Z M 111,27 L 111,41 L 125,41 C 130,41 133,38 133,34 C 133,30 130,27 125,27 Z M 111,54 L 111,69 L 126,69 C 131,69 135,66 135,61 C 135,57 131,54 126,54 Z" fill="#0B3C49" />

    <!-- A -->
    <path d="M 197,84 L 190,66 L 169,66 L 162,84 C 160,88 155,89 151,87 C 147,85 146,80 148,76 L 171,18 C 173,14 176,12 180,12 C 183,12 187,14 188,18 L 211,76 C 213,80 211,85 208,87 C 204,89 199,88 197,84 Z M 179,37 L 173,53 L 186,53 Z" fill="#0B3C49" />

    <!-- N -->
    <path d="M 230,84 L 230,20 C 230,15 234,12 239,12 C 243,12 246,14 248,17 L 280,63 L 280,20 C 280,15 284,12 289,12 C 294,12 298,15 298,20 L 298,76 C 298,81 294,84 289,84 C 285,84 282,82 280,79 L 248,33 L 248,76 C 248,81 244,84 239,84 C 234,84 230,81 230,84 Z" fill="#0B3C49" />

    <!-- D -->
    <path d="M 319,84 L 319,20 C 319,15 323,12 328,12 L 348,12 C 370,12 384,27 384,48 C 384,69 370,84 348,84 L 328,84 C 323,84 319,81 319,84 Z M 338,27 L 338,69 L 348,69 C 360,69 367,60 367,48 C 367,36 360,27 348,27 Z" fill="#0B3C49" />

    <!-- H -->
    <path d="M 405,84 L 405,20 C 405,15 409,12 414,12 C 419,12 423,15 423,20 L 423,41 L 449,41 L 449,20 C 449,15 453,12 458,12 C 463,12 467,15 467,20 L 467,76 C 467,81 463,84 458,84 C 453,84 449,81 449,76 L 449,54 L 423,54 L 423,76 C 423,81 419,84 414,84 C 409,84 405,81 405,84 Z" fill="#0B3C49" />

    <!-- U (with subtle harmonious Sage finish) -->
    <path d="M 488,20 L 488,58 C 488,74 500,85 517,85 C 534,85 546,74 546,58 L 546,20 C 546,15 550,12 555,12 C 560,12 564,15 564,20 L 564,58 C 564,83 544,99 517,99 C 490,99 470,83 470,58 L 470,20 C 470,15 474,12 479,12 C 484,12 488,15 488,20 Z" fill="#145E6F" />

    <!-- Elegant separator dot or leaf flourish between name and tagline -->
    <circle cx="300" cy="115" r="3" fill="#5E8C76" />
    <line x1="160" y1="115" x2="280" y2="115" stroke="#D5E2DA" stroke-width="1.2" stroke-linecap="round" />
    <line x1="320" y1="115" x2="440" y2="115" stroke="#D5E2DA" stroke-width="1.2" stroke-linecap="round" />

    <!-- Tagline: AI Cognitive Care Companion -->
    <text x="300" y="145" 
          text-anchor="middle" 
          font-family="system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif" 
          font-size="14.5" 
          font-weight="600" 
          letter-spacing="4.5" 
          fill="#4E7865">AI COGNITIVE CARE COMPANION</text>
  </g>
</svg>'''

with open(os.path.join(LOGO_DIR, "bandhu-logo-full.svg"), "w", encoding="utf-8") as f:
    f.write(full_logo_svg.strip())

# 3. Horizontal Logo (for Dashboards, Navbars, Header Banners)
horizontal_logo_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 880 260" width="100%" height="100%">
  <defs>
    <linearGradient id="hzTealGrad" x1="0%" y1="100%" x2="50%" y2="0%">
      <stop offset="0%" stop-color="#0B3C49" />
      <stop offset="100%" stop-color="#145E6F" />
    </linearGradient>

    <linearGradient id="hzSageGrad" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#4E7865" />
      <stop offset="60%" stop-color="#6F9D87" />
      <stop offset="100%" stop-color="#8DB69F" />
    </linearGradient>

    <linearGradient id="hzOrbitGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#8DB69F" stop-opacity="0.2" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.8" />
      <stop offset="100%" stop-color="#145E6F" stop-opacity="0.9" />
    </linearGradient>

    <radialGradient id="hzNodeGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#A4E2C6" stop-opacity="1" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.4" />
      <stop offset="100%" stop-color="#5E8C76" stop-opacity="0" />
    </radialGradient>
  </defs>

  <!-- EMBLEM SCALED (Left Side) -->
  <g transform="translate(15, -10) scale(0.58)">
    <path d="M 125,275 C 95,220 110,135 180,85 C 240,40 330,48 385,100 C 428,140 435,210 395,275 C 360,332 290,395 250,420" 
          fill="none" stroke="url(#hzOrbitGrad)" stroke-width="3" stroke-linecap="round" stroke-dasharray="320 8 4 8" />

    <circle cx="398" cy="120" r="14" fill="url(#hzNodeGlow)" />
    <circle cx="398" cy="120" r="6" fill="#145E6F" />
    <circle cx="398" cy="120" r="3.5" fill="#C8EADB" />

    <circle cx="118" cy="245" r="4" fill="#6F9D87" opacity="0.8" />
    <circle cx="118" cy="245" r="2" fill="#FAF8F5" />

    <!-- Companion Ribbon -->
    <path d="M 250,410 C 285,385 355,330 380,265 C 405,200 390,130 340,95 C 295,65 245,95 245,135 C 245,175 285,195 320,185 C 345,178 358,155 350,135 C 335,100 290,85 255,115 C 280,105 315,110 330,135 C 340,152 328,172 305,176 C 275,182 235,160 235,125 C 235,80 290,45 348,78 C 408,112 425,190 395,260 C 368,322 300,378 250,410 Z" fill="url(#hzSageGrad)" />

    <!-- Elder Embrace Ribbon -->
    <path d="M 250,410 C 205,378 135,320 108,255 C 80,188 95,112 158,78 C 200,55 242,75 250,115 C 242,88 208,72 170,88 C 120,110 102,175 125,238 C 148,298 210,355 250,388 C 256,383 252,408 250,410 Z" fill="url(#hzTealGrad)" />
    <path d="M 235,396 C 245,412 255,412 265,396 C 255,404 245,404 235,396 Z" fill="#0B3C49" />

    <!-- Leaf Motif -->
    <g transform="translate(112, 140) rotate(-22)">
      <path d="M 0,40 C -15,25 -25,-5 5,-30 C 20,-5 20,20 0,40 Z" fill="#6F9D87" />
      <path d="M 0,38 C 2,15 4,-5 5,-28" stroke="#FAF8F5" stroke-width="1.8" stroke-linecap="round" opacity="0.7" fill="none" />
      <path d="M -8,18 C -22,12 -28,-2 -12,-16 C -2,0 0,10 -8,18 Z" fill="#8DB69F" opacity="0.9" />
    </g>

    <circle cx="295" cy="195" r="23" fill="#4E7865" />
    <path d="M 295,225 C 315,228 335,245 338,275 L 338,325 C 325,330 305,332 290,320 L 290,265 C 278,262 258,266 242,282 C 236,288 228,284 230,276 C 236,252 262,235 295,225 Z" fill="#5E8C76" />

    <circle cx="218" cy="225" r="21" fill="#0B3C49" />
    <path d="M 200,222 C 198,202 214,194 230,198 C 240,201 245,210 244,218 C 238,212 230,208 218,210 C 208,212 203,218 200,222 Z" fill="#D5E2DA" />
    <circle cx="199" cy="216" r="7.5" fill="#D5E2DA" />
    <path d="M 226,250 C 245,255 252,275 252,310 C 242,328 220,335 198,328 C 188,320 182,300 185,280 C 188,260 205,248 226,250 Z" fill="#0F4C5C" />
    <path d="M 225,280 C 235,270 252,270 262,282" stroke="#FAF8F5" stroke-width="3" stroke-linecap="round" opacity="0.4" fill="none" />
  </g>

  <!-- TYPOGRAPHY RIGHT SIDE -->
  <g transform="translate(300, 30)">
    <!-- BANDHU -->
    <g transform="scale(1.2)">
      <!-- B -->
      <path d="M 12,72 L 12,20 C 12,15 16,12 21,12 L 46,12 C 60,12 69,19 69,30 C 69,37 64,43 57,45 C 66,47 72,55 72,64 C 72,76 61,84 46,84 L 21,84 C 16,84 12,80 12,75 Z M 31,27 L 31,41 L 45,41 C 50,41 53,38 53,34 C 53,30 50,27 45,27 Z M 31,54 L 31,69 L 46,69 C 51,69 55,66 55,61 C 55,57 51,54 46,54 Z" fill="#0B3C49" />
      <!-- A -->
      <path d="M 117,84 L 110,66 L 89,66 L 82,84 C 80,88 75,89 71,87 C 67,85 66,80 68,76 L 91,18 C 93,14 96,12 100,12 C 103,12 107,14 108,18 L 131,76 C 133,80 131,85 128,87 C 124,89 119,88 117,84 Z M 99,37 L 93,53 L 106,53 Z" fill="#0B3C49" />
      <!-- N -->
      <path d="M 150,84 L 150,20 C 150,15 154,12 159,12 C 163,12 166,14 168,17 L 200,63 L 200,20 C 200,15 204,12 209,12 C 214,12 218,15 218,20 L 218,76 C 218,81 214,84 209,84 C 205,84 202,82 200,79 L 168,33 L 168,76 C 168,81 164,84 159,84 C 154,84 150,81 150,84 Z" fill="#0B3C49" />
      <!-- D -->
      <path d="M 239,84 L 239,20 C 239,15 243,12 248,12 L 268,12 C 290,12 304,27 304,48 C 304,69 290,84 268,84 L 248,84 C 243,84 239,81 239,84 Z M 258,27 L 258,69 L 268,69 C 280,69 287,60 287,48 C 287,36 280,27 268,27 Z" fill="#0B3C49" />
      <!-- H -->
      <path d="M 325,84 L 325,20 C 325,15 329,12 334,12 C 339,12 343,15 343,20 L 343,41 L 369,41 L 369,20 C 369,15 373,12 378,12 C 383,12 387,15 387,20 L 387,76 C 387,81 383,84 378,84 C 373,84 369,81 369,76 L 369,54 L 343,54 L 343,76 C 343,81 339,84 334,84 C 329,84 325,81 325,84 Z" fill="#0B3C49" />
      <!-- U -->
      <path d="M 408,20 L 408,58 C 408,74 420,85 437,85 C 454,85 466,74 466,58 L 466,20 C 466,15 470,12 475,12 C 480,12 484,15 484,20 L 484,58 C 484,83 464,99 437,99 C 410,99 390,83 390,58 L 390,20 C 390,15 394,12 399,12 C 404,12 408,15 408,20 Z" fill="#145E6F" />
    </g>

    <!-- Subtitle Tagline -->
    <g transform="translate(15, 140)">
      <text x="0" y="16" 
            font-family="system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif" 
            font-size="16.5" 
            font-weight="600" 
            letter-spacing="5.5" 
            fill="#4E7865">AI COGNITIVE CARE COMPANION</text>
      <line x1="0" y1="32" x2="480" y2="32" stroke="#E3ECE6" stroke-width="1.5" stroke-linecap="round" />
    </g>
  </g>
</svg>'''

with open(os.path.join(LOGO_DIR, "bandhu-logo-horizontal.svg"), "w", encoding="utf-8") as f:
    f.write(horizontal_logo_svg.strip())

# 4. Mobile App Icon (Ready for iOS / Android / Web PWA)
app_icon_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="100%" height="100%">
  <defs>
    <!-- Background Gradient (Warm Cream to Soft Pearl) -->
    <linearGradient id="iconBgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FCFAF7" />
      <stop offset="100%" stop-color="#F3EFEA" />
    </linearGradient>

    <!-- Squircle Clip -->
    <clipPath id="squircle">
      <rect x="0" y="0" width="512" height="512" rx="115" ry="115" />
    </clipPath>

    <linearGradient id="aiTealGrad" x1="0%" y1="100%" x2="50%" y2="0%">
      <stop offset="0%" stop-color="#0B3C49" />
      <stop offset="100%" stop-color="#145E6F" />
    </linearGradient>

    <linearGradient id="aiSageGrad" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#4E7865" />
      <stop offset="60%" stop-color="#6F9D87" />
      <stop offset="100%" stop-color="#8DB69F" />
    </linearGradient>

    <linearGradient id="aiOrbitGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#8DB69F" stop-opacity="0.3" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.9" />
      <stop offset="100%" stop-color="#145E6F" stop-opacity="0.9" />
    </linearGradient>

    <radialGradient id="aiNodeGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#A4E2C6" stop-opacity="1" />
      <stop offset="50%" stop-color="#5E8C76" stop-opacity="0.5" />
      <stop offset="100%" stop-color="#5E8C76" stop-opacity="0" />
    </radialGradient>
  </defs>

  <!-- SQUIRCLE APP ICON CONTAINER -->
  <g clip-path="url(#squircle)">
    <!-- Background -->
    <rect x="0" y="0" width="512" height="512" fill="url(#iconBgGrad)" />

    <!-- Subtle Premium Inner Border -->
    <rect x="1.5" y="1.5" width="509" height="509" rx="114" ry="114" fill="none" stroke="#E6E0D8" stroke-width="2" />

    <!-- Centered Emblem -->
    <g transform="translate(36, 40) scale(0.88)">
      <!-- Neural Orbit Arc -->
      <path d="M 125,275 C 95,220 110,135 180,85 C 240,40 330,48 385,100 C 428,140 435,210 395,275 C 360,332 290,395 250,420" 
            fill="none" stroke="url(#aiOrbitGrad)" stroke-width="3.5" stroke-linecap="round" stroke-dasharray="320 8 4 8" />

      <!-- Neural Orbit Node -->
      <circle cx="398" cy="120" r="16" fill="url(#aiNodeGlow)" />
      <circle cx="398" cy="120" r="7" fill="#145E6F" />
      <circle cx="398" cy="120" r="4" fill="#C8EADB" />

      <circle cx="118" cy="245" r="4.5" fill="#6F9D87" opacity="0.85" />
      <circle cx="118" cy="245" r="2.2" fill="#FAF8F5" />

      <!-- Right Embrace Arm (Companion / Sage Green) -->
      <path d="M 250,410 
               C 285,385 355,330 380,265 
               C 405,200 390,130 340,95 
               C 295,65 245,95 245,135 
               C 245,175 285,195 320,185 
               C 345,178 358,155 350,135 
               C 335,100 290,85 255,115
               C 280,105 315,110 330,135
               C 340,152 328,172 305,176
               C 275,182 235,160 235,125
               C 235,80 290,45 348,78
               C 408,112 425,190 395,260
               C 368,322 300,378 250,410 Z" 
            fill="url(#aiSageGrad)" />

      <!-- Left Embrace Arm (Teal) -->
      <path d="M 250,410 
               C 205,378 135,320 108,255 
               C 80,188 95,112 158,78 
               C 200,55 242,75 250,115 
               C 242,88 208,72 170,88 
               C 120,110 102,175 125,238 
               C 148,298 210,355 250,388 
               C 256,383 252,408 250,410 Z" 
            fill="url(#aiTealGrad)" />

      <path d="M 235,396 C 245,412 255,412 265,396 C 255,404 245,404 235,396 Z" fill="#0B3C49" />

      <!-- Leaf Motif -->
      <g transform="translate(112, 140) rotate(-22)">
        <path d="M 0,40 C -15,25 -25,-5 5,-30 C 20,-5 20,20 0,40 Z" fill="#6F9D87" />
        <path d="M 0,38 C 2,15 4,-5 5,-28" stroke="#FAF8F5" stroke-width="1.8" stroke-linecap="round" opacity="0.7" fill="none" />
        <path d="M -8,18 C -22,12 -28,-2 -12,-16 C -2,0 0,10 -8,18 Z" fill="#8DB69F" opacity="0.9" />
      </g>

      <!-- Companion Silhouette -->
      <circle cx="295" cy="195" r="23" fill="#4E7865" />
      <path d="M 295,225 
               C 315,228 335,245 338,275 
               L 338,325 
               C 325,330 305,332 290,320 
               L 290,265 
               C 278,262 258,266 242,282 
               C 236,288 228,284 230,276 
               C 236,252 262,235 295,225 Z" 
            fill="#5E8C76" />

      <!-- Elder Silhouette -->
      <circle cx="218" cy="225" r="21" fill="#0B3C49" />
      <path d="M 200,222 
               C 198,202 214,194 230,198 
               C 240,201 245,210 244,218 
               C 238,212 230,208 218,210 
               C 208,212 203,218 200,222 Z" 
            fill="#D5E2DA" />
      <circle cx="199" cy="216" r="7.5" fill="#D5E2DA" />
      <path d="M 226,250 
               C 245,255 252,275 252,310 
               C 242,328 220,335 198,328 
               C 188,320 182,300 185,280 
               C 188,260 205,248 226,250 Z" 
            fill="#0F4C5C" />

      <path d="M 225,280 C 235,270 252,270 262,282" stroke="#FAF8F5" stroke-width="3" stroke-linecap="round" opacity="0.4" fill="none" />
    </g>
  </g>
</svg>'''

with open(os.path.join(LOGO_DIR, "bandhu-app-icon.svg"), "w", encoding="utf-8") as f:
    f.write(app_icon_svg.strip())

# 5. Dark Mode App Icon
dark_app_icon_svg = app_icon_svg.replace(
    '<stop offset="0%" stop-color="#FCFAF7" />',
    '<stop offset="0%" stop-color="#08232B" />'
).replace(
    '<stop offset="100%" stop-color="#F3EFEA" />',
    '<stop offset="100%" stop-color="#05171D" />'
).replace(
    'stroke="#E6E0D8"',
    'stroke="#145E6F"'
)

with open(os.path.join(LOGO_DIR, "bandhu-app-icon-dark.svg"), "w", encoding="utf-8") as f:
    f.write(dark_app_icon_svg.strip())

print("All SVG assets successfully written to:", LOGO_DIR)
