# poster.rb: make a poster.
#
# Time-stamp: <2025-04-12 19:06:31 (mkmcc)>
#
# Style:
#   1. the parameters in enter_page control the layout.  these are:
#      a. the figure margins
#      b. the margin separating columns
#      c. header/footer height
#      d. "tilt"
#
require 'Tioga/FigureMaker'
require 'Dobjects/Function'
require 'plot_styles.rb'
require 'read_vtk.rb'

class MyPlots

  include Math
  include Tioga
  include FigureConstants
  include MyPlotStyles

  def t
    @figure_maker
  end


  def initialize
    @figure_maker = FigureMaker.default

    enter_page

    t.tex_preview_preamble += \
    "\n\t\\usepackage[onlymath,medfamily,opticals]{MinionPro}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{ArnoPro}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{wrapfig}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{enumitem}\n"

    t.tex_preview_preamble += "\n\t\\usepackage[stretch=30,shrink=30]{microtype}\n"

    # Sizes of frames
    @head_height = 0.10
    @foot_height = 0.07

    # margins between frames
    @hsep = 0.01
    @vsep = @hsep * t.default_page_width / t.default_page_height

    # "tilt" of the frames
    @top_tilt = 0.25
    @bot_tilt = @top_tilt * @head_height / @foot_height


    # define the solarized color pallette
    @base03  = [ 0.0000, 0.1686, 0.2117 ]
    @base02  = [ 0.0274, 0.2117, 0.2588 ]
    @base01  = [ 0.3450, 0.4313, 0.4588 ]
    @base00  = [ 0.3960, 0.4823, 0.5137 ]
    @base0   = [ 0.5137, 0.5803, 0.5882 ]
    @base1   = [ 0.5764, 0.6313, 0.6313 ]
    @base2   = [ 0.9333, 0.9098, 0.8352 ]
    @base3   = [ 0.9921, 0.9647, 0.8901 ]
    @yellow  = [ 0.7098, 0.5372, 0.0000 ]
    @orange  = [ 0.7960, 0.2941, 0.0862 ]
    @red     = [ 0.8627, 0.1960, 0.1843 ]
    @magenta = [ 0.8274, 0.2117, 0.5098 ]
    @violet  = [ 0.4235, 0.4431, 0.7686 ]
    @blue    = [ 0.1490, 0.5450, 0.8235 ]
    @cyan    = [ 0.1647, 0.6313, 0.5960 ]
    @green   = [ 0.5215, 0.6000, 0.0000 ]

    @page_background_color   = @base2
    @column_background_color = @base3
    @title_text_color        = FireBrick
    @author_text_color       = DarkGoldenrod
    @body_text_color         = [0.1, 0.1, 0.1]
    @section_text_color      = @blue.map{|c| 0.75 * c}

    rgb = @body_text_color.join(",")
    t.tex_preview_preamble += "\n\t\\definecolor{mytext}{rgb}{#{rgb}}\n"
    t.tex_preview_preamble += "\n\t\\color{mytext}\n"

    t.def_figure('gas-clouds') { make_poster }
  end

  def enter_page
    set_default_plot_style

    t.default_page_width  = 72 * 8.5
    t.default_page_height = 72 * 11

    # Set an outside margin
    outside_margin = 0.01
    t.default_frame_left   = outside_margin
    t.default_frame_right  = (1.00 - outside_margin)
    t.default_frame_top    = 1.00 - \
      outside_margin * (t.default_page_width / t.default_page_height)
    t.default_frame_bottom = \
      outside_margin * (t.default_page_width / t.default_page_height)

    t.default_enter_page_function
  end

  def make_poster
    # Make a background color
    a = -0.01
    b = a*(t.default_page_width / t.default_page_height)
    t.subplot('left_margin'   => a,
              'right_margin'  => a,
              'top_margin'    => b,
              'bottom_margin' => b) do

      t.fill_color   = @page_background_color
      t.fill_frame
    end

    t.subplot('bottom_margin' => 1.0-@head_height) { mk_title }
    t.subplot('top_margin'    => 1.0-@foot_height) { mk_footer }

    # four-column layout: (straightforward to change)
    # ncols = 2.0
    # size  = (1.0 - (ncols-1)*@hsep)/ncols
    # skip  = size + @hsep

    # mk_col(0*skip, 1*skip){ first_col  }
    # mk_col(1*skip, 0*skip){ second_col }

    # four-column layout: (straightforward to change)
    ncols = 3.0
    size  = (1.0 - (ncols-1)*@hsep)/ncols
    skip  = size + @hsep

    mk_col(0*skip, 2*skip){ first_col  }
    mk_col(1*skip, 1*skip){ second_col }
    mk_col(2*skip, 0*skip){ last_col }
  end

  def section_fmt(text)
    '\fontsize{16}{16}\selectfont\textsc{' + text + '}'
  end

  def title_fmt(text)
    '\fontsize{42}{42}\selectfont\textsc{ ' + text + '}'
  end

  def subtitle_fmt(text)
    '\fontsize{16}{16}\selectfont\textsc{ ' + text + '}'
  end

  def author_fmt(text)
    '\fontsize{12}{12}\selectfont\textit{ ' + text + '}'
  end

  def mk_title
    stroke_bdy([0,           1,           1, 0],
               [0-@top_tilt, 0+@top_tilt, 1, 1])

    title = title_fmt('Why Didn\'t G2 Disrupt?')

    t.show_text('text'          => title,
                'at'            => [0.5, 0.9],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => CENTERED,
                'color'         => @title_text_color)

    subtitle = subtitle_fmt('--- Magnetic Support, Orbital Twisting, and the Invisible Galactic Center ---')

    t.show_text('text'          => subtitle,
                'at'            => [0.5, 0.4],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => CENTERED,
                'color'         => @title_text_color)

    authors = 'Mike McCourt, Ann-Marie Madigan, \& Ryan O\'Leary'
    authors = author_fmt(authors)

    t.show_text('text'          => authors,
                'at'            => [0.07, -0.15],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED,
                'color'         => @author_text_color,
                'angle' => atan(2.0*@top_tilt*@head_height) * 180/3.14159)

  end

  def mk_footer
    stroke_bdy([0, 1, 1,           0],
               [0, 0, 1+@bot_tilt, 1-@bot_tilt])

    t.show_text('text'          => '\textcopyright\ authors 2013',
                'at'            => [0.005, 0.1],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text'          => '\fontsize{20}{20}\selectfont\textsc{References}',
                'at'            => [0.995, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @title_text_color)

    refs = 'McCourt et al. (2015), McCourt \& Madigan (2016), Madigan, McCourt, \& O\'Leary (2017)'

    refs = "\\fontsize{12}{12}\\selectfont \\textit{#{refs}}"

    t.show_text('text'          => refs,
                'at'            => [0.995, 0.2],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => RIGHT_JUSTIFIED,
                'color' => @author_text_color)
  end


  # Calculate margins for a column and set up a subplot environment.
  #   Execute the supplied block in the subplot
  #
  def mk_col(left, right)
    @col_width = (1-left-right)*t.default_page_width/72

    topofst = @top_tilt * @head_height
    topofst *= (1.0 - 2*left)

    botofst = @bot_tilt * @foot_height
    botofst *= (2*right - 1.0)

    t.subplot({ 'left_margin'   => left,
                'right_margin'  => right,
                'top_margin'    => @head_height+topofst+@vsep,
                'bottom_margin' => @foot_height-botofst+@vsep}) do

      dy = @top_tilt * @head_height/(1.0-@head_height-@foot_height-2*@vsep)
      dy *= (1.0-left-right)*2

      stroke_bdy([0, 1, 1, 0],
                 [0-dy, 0, 1+dy, 1])

      @col_width = (1.0-left-right) # tioga units
      @line_width = t.default_page_width * @col_width / 72 # in

      yield
    end
  end

  # Stroke the boundary of a frame
  #
  def stroke_bdy(x_vals, y_vals)
    t.line_width = 0.25
    t.line_join = LINE_JOIN_MITER
    t.fill_color = @column_background_color

    t.append_points_to_path(x_vals, y_vals)
    t.close_path

    t.fill_and_stroke
  end

  # helper function for grid, below
  #
  def marker(x, y, just)
    t.show_text('at' => [x, y],
                'text' => '\color{red}{\_'+y.to_s+'\_}',
                'justification' => just,
                'alignment' => ALIGNED_AT_BASELINE)
  end

  # Overlay a grid on the current subplot.  Useful for layout.
  #
  def grid
     (0..10).each do |i|
      marker(0.0, i.to_f/10, LEFT_JUSTIFIED)
      marker(0.5, i.to_f/10, CENTERED)
      marker(1.0, i.to_f/10, RIGHT_JUSTIFIED)
    end
  end


  # Format text as a minipage takes width in tioga units (fraction of
  # column width)
  #
  def minipage(text, width)
    physical_width = t.default_page_width \
    * (t.default_frame_right-t.default_frame_left) \
    * @col_width * width \
    / 72.0

    mtext = '\begin{minipage}{'+physical_width.to_s+'in} '\
    + '\fontsize{12}{14}\selectfont '\
    + text + ' \end{minipage}'

    mtext
  end

  # Include an image file.  Takes a width in tioga units (fraction of
  # current subplot).
  #
  def image(file, width)
    physical_width = t.default_page_width \
    * (t.default_frame_right-t.default_frame_left) \
    * @col_width * width \
    / 72.0

    text = '\includegraphics[width=' + physical_width.to_s \
           + 'in]{'+file+'}'

    text
  end

  # Make a square wrapfig of size height lines
  #
  def wrap_image(file, height, alignment="l", width_fact=1)
    text = "\\includegraphics[height=#{(height-0.5).to_s}\\baselineskip]{#{file}}"

    text = "\\begin{wrapfigure}[#{height.to_s}]{#{alignment}}{#{(width_fact*height-0.7).to_s}\\baselineskip}
           \\vspace{-\\baselineskip}%
           #{text}
           \\end{wrapfigure} \n"

    text
  end

  def caption_fmt(text)
    '\\fontsize{10}{12}\\selectfont{' + text + '}'
  end


  ##############################################################################
  ### Content
  def first_col
    t.show_text('text'          => section_fmt('Introduction'),
                'at'            => [0.98, 1.0125],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 2.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = "A gas cloud known as \\textit{G2}
    passed close to the black hole at the center of our galaxy in
    2014.  Conventional simulations predicted it would be torn apart
    by \\textit{shear instabilities}---but observations show the cloud
    largely \\textit{survived}."


    example_text = example_text + "\\\\*[2ex] \n" + "This tension
    suggested that something important was missing from the models.
    We show that \\textit{magnetic fields} fundamentally change the fate of
    gas clouds like G2, and that their orbits can be used to probe the
    structure and dynamics of the galactic center."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.97],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)

    # Method
    # t.show_text('text'          => section_fmt('Magnetic Fields Stabilize Gas Clouds'),
    #             'at'            => [0.98, 0.7],
    #             'alignment'     => ALIGNED_AT_TOP,
    #             'justification' => RIGHT_JUSTIFIED,
    #             'color'         => @section_text_color)

    rgb = @section_text_color.join(",")
    example_text = "{\\color{mytempcolor} Magnetic Fields Stabilize Gas Clouds}"
    example_text = section_fmt("\\raggedleft #{example_text} \\par")
    example_text = minipage(example_text, 0.7)

    example_text = "\\definecolor{mytempcolor}{rgb}{#{rgb}} " + example_text

    t.show_text('text'          => example_text,
                'at'            => [0.98, 0.64],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)


    example_text = image('figures/mhd-hydro-comp.pdf', 0.96)

    example_text = example_text + "\\\\*[2ex] \n Early simulations of
    G2 modeled the cloud as a simple, non-magnetic fluid.  In these
    simulations, the cloud disrupts rapidly due to
    \\textit{Kelvin-Helmholtz instabilities}."

    example_text = example_text + "\\\\*[2ex] \n We performed
    magnetohydrodynamic (\\textsc{mhd}) simulations and found a
    striking result: even \\textit{weak magnetic fields} can stabilize
    the cloud, suppressing its disruption and extending its lifetime.
    This helps explain why G2 remained intact longer than expected—and
    reduces the need to revise estimates of gas density in the
    galactic center."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.0],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)


    # grid
  end

  def second_col
    # saturation plot
    # t.show_text('text'          => section_fmt('Using G2 to Probe the Galactic Center'),
    #             'at'            => [0.98, 1.01],
    #             'alignment'     => ALIGNED_AT_TOP,
    #             'justification' => RIGHT_JUSTIFIED,
    #             'color'         => @section_text_color,
    #             'angle' => 2.0*atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    rgb = @section_text_color.join(",")
    example_text = "{\\color{mytempcolor} Using G2 to Probe the Galactic Center}"
    example_text = section_fmt("\\raggedleft #{example_text} \\par")
    example_text = minipage(example_text, 0.7)

    example_text = "\\definecolor{mytempcolor}{rgb}{#{rgb}} " + example_text

    t.show_text('text'          => example_text,
                'at'            => [0.98, 1.01],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)

    example_text = "While much attention focused on G2's potential for
    fueling the black hole, it also acts as a \\textit{test particle:}
    its trajectory encodes information about the \\textit{rotation,
    density, and magnetic field} of the background gas."

    example_text = example_text + "\\\\*[2ex] \n"

    example_text = example_text + "We developed a dynamical model that
    accounts for: \\begin{itemize}[leftmargin=*,itemsep=-1ex,] \\item
    \\textit{Magnetically enhanced drag,} acting between the cloud and
    the rotating medium \\item \\textit{Orbital precession,} as the
    plane of G2’s orbit twists to align with the accretion flow \\item
    The cloud's evolution across \\textit{multiple pericenter
    passages} \\end{itemize}"

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "Our model explains not only G2's
    orbit, but also that of a similar cloud, \\textit{G1}, which
    shares its trajectory but shows more orbital decay---consistent with
    earlier infall and drag."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.94],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)


    # t.show_text('text'          => section_fmt('Observational Constraints and Predictions'),
    #             'at'            => [0.98, 0.475],
    #             'alignment'     => ALIGNED_AT_TOP,
    #             'justification' => RIGHT_JUSTIFIED,
    #             'color'         => @section_text_color,
    #             'angle' => 0.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    rgb = @section_text_color.join(",")
    example_text = "{\\color{mytempcolor} Observational Constraints and Predictions}"
    example_text = section_fmt("\\raggedleft #{example_text} \\par")
    example_text = minipage(example_text, 0.96)

    example_text = "\\definecolor{mytempcolor}{rgb}{#{rgb}} " + example_text

    t.show_text('text'          => example_text,
                'at'            => [0.98, 0.52],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)

    example_text = "We used the G1/G2 system to \\textit{fit a
    dynamical model} of cloud evolution in a rotating, magnetized
    background.  We used numerical orbital simulations, with
    Markov-Chain Monte Carlo to constrain our model parameters."

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + image('figures/sim-vs-data.pdf', 0.96)

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "Though it looks slightly crazy,
    this orbit is in fact entirely consistent with the observations,
    both in the plane of the sky, and along the line of
    sight. \\textbf{\\textit{This model does just as well as fitting
    G1 and G2 with two unrelated Keplerian orbits}}."

    t.show_text('text'          => minipage(example_text, 0.96),
                #'at'            => [0.02, 0.46],
                'at'            => [0.02, 0.00],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)

    # grid
  end

  def last_col
    rgb = @section_text_color.join(",")
    example_text = "{\\color{mytempcolor} Constraining Galactic Center Parameters}"
    example_text = section_fmt("\\raggedleft #{example_text} \\par")
    example_text = minipage(example_text, 0.96)

    example_text = "\\definecolor{mytempcolor}{rgb}{#{rgb}} " + example_text

    t.show_text('text'          => example_text,
                'at'            => [0.98, 1.01],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)

    example_text = ''

    example_text = example_text + "By comparing with to astrometry and
    spectroscopy, we inferred \\textit{probability distributions} for
    six key parameters:"

    example_text = example_text + "\\begin{itemize}[leftmargin=*,itemsep=-1ex,]
    \\item \\textit{Rotation axis} of the galactic center accretion flow
    \\item  \\textit{Magnetic field strength} and \\textit{density profile} (degenerate with
    each other)
    \\item \\textit{Shape of the cloud}
    \\item \\textit{Rotation profile} of the background gas
    \\end{itemize}"

    example_text = example_text + "Our model matches the full 3D orbit
    and velocity evolution of both G1 and G2—including the
    \\textit{twisting of the orbital plane} and the observed
    \\textit{orbital energy difference} between the clouds."

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + image('figures/scatter-plots-short.pdf', 0.96)

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "We find that the
    \\textbf{\\textit{rotation axis is tightly constrained}}---a
    prediction that can be tested by \\textit{upcoming EHT
    observations}.  Other parameters remain degenerate, but could be
    constrained with independent measurements (e.\\,g., magnetic field
    strength via polarization)."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.93],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)



    t.show_text('text'          => section_fmt('What\'s Next?'),
                'at'            => [0.98, 0.280],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 0.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)


    example_text = wrap_image('figures/t-peri-website.pdf', height=5, alignment="l", width_fact=1.4)

    example_text = example_text + "Our model predicts a delay in G2's
    closest approach to the black hole, after most of the observing
    campaigns monitoring G2 ended, but \\textit{consistent with
    flaring activity observed in late 2014}.  This work provides a
    framework for using future infalling clouds to \\textit{map the
    hidden structure} of the galactic center and to test theories of
    black hole accretion.  "

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.00],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)

    # grid
  end

end

MyPlots.new


# Local Variables:
#   compile-command: "tioga buoyancy-saturation.rb -s"
# End:
