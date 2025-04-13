# poster.rb: make a poster.
#
# Time-stamp: <2025-04-13 08:59:55 (mkmcc)>
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
    "\n\t\\usepackage[medfamily,opticals]{MinionPro}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{wrapfig}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{enumitem}\n"

    t.tex_preview_preamble += \
    "\t\t\\usepackage{pifont}
\\newcommand{\\cmark}{\\ding{51}}%
\\newcommand{\\xmark}{\\ding{55}}%\n"

    t.tex_preview_preamble += "\n\t\\usepackage[stretch=70,shrink=70]{microtype}\n"

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
    @subsection_text_color   = @green.map{|c| 0.75 * c}

    rgb = @body_text_color.join(",")
    t.tex_preview_preamble += "\n\t\\definecolor{mytext}{rgb}{#{rgb}}\n"
    t.tex_preview_preamble += "\n\t\\color{mytext}\n"

    t.def_figure('inclination-instability') { make_poster }
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
    ncols = 1.0
    size  = (1.0 - (ncols-1)*@hsep)/ncols
    skip  = size + @hsep

    mk_col(0*skip, 0*skip){ first_col  }
  end

  def section_fmt(text)
    '\fontsize{16}{16}\selectfont\textsc{' + text + '}'
  end

  def subsection_fmt(text)
    '\fontsize{14}{14}\selectfont\textsc{' + text + '}'
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

    title = title_fmt('Do We Need Planet 9?')

    t.show_text('text'          => title,
                'at'            => [0.5, 0.8],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => CENTERED,
                'color'         => @title_text_color)

    authors = 'Ann-Marie Madigan \& Mike McCourt'
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

    t.show_text('text'          => '\textcopyright\ authors 2018',
                'at'            => [0.005, 0.1],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text'          => '\fontsize{20}{20}\selectfont\textsc{References}',
                'at'            => [0.995, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @title_text_color)

    refs = 'Madigan \& McCourt (2016), Madigan et al. (2018)'

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
                'at'            => [0.98, 1.04],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 2.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = wrap_image('figures/plutos.png', 12, 'l', 1.1)

    example_text = example_text + "As more and more distant minor
    planets---like Pluto---are being found, it\'s become clear that
    they follow \\textbf{oddly aligned} orbits.  Rather than being
    randomly tilted, their orbits: "

    example_text = example_text + "\\begin{itemize}\n"

    example_text = example_text + "\\item Have \\textbf{high
    inclinations} (tilted well out of the ecliptic)"

    example_text = example_text + "\\item Are \\textbf{clustered} in
    argument of pericenter $\\omega$, collectively forming a
    \\textbf{cone-like structure}"

    example_text = example_text + "\\end{itemize}"

    example_text = example_text + "These patterns are difficult to
    explain with classical planetary dynamics.  So—what’s going on in
    the outer solar system?"

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.98],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)



    t.show_text('text'          => section_fmt('Two Competing Explanations'),
                'at'            => [0.98, 0.74],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 0.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    tmp_height_1 = 0.72
    tmp_height_2 = 0.69
    t.show_text('text'          => subsection_fmt('Planet 9 Hypothesis'),
                'at'            => [0.25, tmp_height_1],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => CENTERED,
                'color'         => @subsection_text_color,
                'angle' => 0.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = "In order to explain the minor planet orbits, some
    authors propose that a massive, undiscovered Neptune-sized planet
    shepherds these orbits into alignment through long-term
    gravitational influence.  This hypothesis: "

    example_text = example_text + "\\begin{itemize}[leftmargin=2em,itemsep=-1ex,]\n"

    example_text = example_text + "\\item[\\cmark] Explains clustering in $\\omega$ \n"

    example_text = example_text + "\\item[\\xmark] Requires a carefully tuned, unseen object"

    example_text = example_text + "\\item[\\xmark] Doesn't naturally explain the \\textbf{high inclinations}"

    example_text = example_text + "\\end{itemize}"

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "In addition, the Planet~9
    hypothesis feels ad-hoc; it is post-dictive, not pre-dictive."

    t.show_text('text'          => minipage(example_text, 0.96/2-0.025),
                'at'            => [0.02, tmp_height_2],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)



    t.show_text('text'          => subsection_fmt('The Inclination Instability'),
                'at'            => [0.75, tmp_height_1],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => CENTERED,
                'color'         => @subsection_text_color,
                'angle' => 0.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = "Ann-Marie Madigan identified a new
    \\textbf{gravitational instability} in nearly radial disks of
    objects like the minor planets.  The key features:"

    example_text = example_text + "\\begin{itemize}[leftmargin=2em,itemsep=-1ex,]\n"

    example_text = example_text + "\\item[\\cmark] Drives \\textit{exponential growth} in inclination \n"

    example_text = example_text + "\\item[\\cmark] Causes \\textit{coherent clustering} in argument of pericenter"

    example_text = example_text + "\\item[\\cmark] Converts a disk into a \\textbf{cone}}"

    example_text = example_text + "\\end{itemize}"

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "This isn't driven by a central
    planet, but by the \\textbf{collective self-gravity} of the disk
    acting over long timescales.  It should always be active, and
    requires no ad hoc assumptions."

    t.show_text('text'          => minipage(example_text, 0.96/2-0.025),
                'at'            => [0.98, tmp_height_2],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)




    t.show_text('text'          => section_fmt('Dynamics of the Inclination Instability'),
                'at'            => [0.98, 0.425],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 0.0 * atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)


    example_text = wrap_image('figures/two-orbit-model.pdf', 15, 'l', 0.6)

    example_text = example_text + "Depiction of the instability in an
    idealized,``two-orbit\'\' toy model.  The top right of each panel
    shows the location of the orbit in the disk from a face-on
    perspective.  Top panel: orbit~1 experiences a net upward force
    $\\vec{f}$.  This force produces a torque along the $\\hat{b}$ axis,
    rotating the orbital plane such that $i_a < 0$."

    t.show_text('text'          => minipage(example_text, 0.96/2.25-0.025),
                'at'            => [0.02, 0.4],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)



    example_text = image('figures/triple.pdf', (0.96-0.96/2.25)-0.025)

    example_text = example_text + "\\\\*[1ex] \n "

    example_text = example_text + "In $N$-body simulations, the
    inclination instability naturally reproduces the key properties
    observed in minor planets: the \\textbf{high inclinations},
    \\textbf{cone-like structure}, and \\textbf{clustering in
    $\\omega$}.  Entirely as a consequence of gravity!"

    example_text = example_text + "\\\\*[1ex] \n "

    example_text = example_text + "\\textbf{We may not need Planet 9
    after all---the minor planets organize themselves.}"

    t.show_text('text'          => minipage(example_text, (0.96-0.96/2.25)-0.025),
                'at'            => [0.98, 0.41],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)



    # grid
  end


end

MyPlots.new


# Local Variables:
#   compile-command: "tioga buoyancy-saturation.rb -s"
# End:
