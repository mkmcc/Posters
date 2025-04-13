# want 1200 px images from 11 inch pdfs.
res = 1200.0 / 11.0

files = [
  './OuterParts/outer-parts.pdf',
  './ThermalInstability/thermal-instability.pdf',
  './BuoyancySaturation/buoyancy-saturation.pdf',
  './GasClouds/gas-clouds.pdf'
]

files.each do |file|
  base = file.chomp(".pdf")
  cmd = "gs -q -sDEVICE=pngalpha -sBATCH -dSAFER -sNOPAUSE "
  cmd += "-r#{res} "
  cmd += "-sOutputFile=#{base}.png #{base}.pdf"
  system cmd
end
