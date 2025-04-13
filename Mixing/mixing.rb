# poster.rb: make a poster.
#
# Time-stamp: <2025-04-12 21:08:53 (mkmcc)>
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

    t.autocleanup = false

    t.tex_preview_preamble += \
    "\n\t\\usepackage[onlymath,medfamily,opticals]{MinionPro}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage[scaled=1.0]{FuturaStd}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{WarnockPro}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{wrapfig}\n"

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

    t.def_figure('mixing') { make_poster }
  end

  def enter_page
    set_default_plot_style

    t.default_page_width  = 72 * 11
    t.default_page_height = 72 * 8.5

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
    ncols = 2.0
    size  = (1.0 - (ncols-1)*@hsep)/ncols
    skip  = size + @hsep

    mk_col(0*skip, 1*skip){ first_col  }
    mk_col(1*skip, 0*skip){ second_col }
  end

  def section_fmt(text)
    '\fontsize{18}{18}\selectfont\textbf{\textsc{' + text + '}}'
  end

  def title_fmt(text)
    '\fontsize{36}{36}\selectfont\textbf{ ' + text + '}'
  end

  def author_fmt(text)
    '\fontsize{16}{16}\selectfont\textit{ ' + text + '}'
  end

  def mk_title
    stroke_bdy([0,           1,           1, 0],
               [0-@top_tilt, 0+@top_tilt, 1, 1])

    title = title_fmt('Mixing and the Mirage of Convergence')

    t.show_text('text'          => title,
                'at'            => [0.0, 0.9],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED,
                'color'         => @title_text_color)

    authors = 'Daniel Lecoanet, Mike McCourt, Eliot Quataert, & Ryan O\'Leary'
    authors = author_fmt(authors)

    t.show_text('text'          => authors,
                'at'            => [0.07, -0.15],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED,
                'color'         => @author_text_color,
                'angle' => 0.725*atan(2.0*@top_tilt*@head_height) * 180/3.14159)

  end

  def mk_footer
    stroke_bdy([0, 1, 1,           0],
               [0, 0, 1+@bot_tilt, 1-@bot_tilt])

    t.show_text('text'          => '\textcopyright\ authors 2016',
                'at'            => [0.005, 0.1],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text'          => '\fontsize{20}{20}\selectfont\textbf{References}',
                'at'            => [0.995, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @title_text_color)

    refs = 'Lecoanet, McCourt, Quataert, Burns, et al. (2007)'

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
    + '\fontsize{10}{12}\selectfont '\
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

    text = '\hspace*{\fill}\includegraphics[width=' + physical_width.to_s \
           + 'in]{'+file+'}\hspace*{\fill}'

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
    '\\textsf{\\textbf{' + text + '}}'
  end


  ##############################################################################
  ### Content
  def first_col
    t.show_text('text'          => section_fmt('Introduction'),
                'at'            => [0.98, 1.01],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = ''
    example_text = example_text + "A strange fact of fluid dynamics:
    \\textbf{fluids don't actually mix}.  The mixing we
    observe---cream into coffee, dye into water---isn't due to
    stirring alone, but to \\textit{molecular diffusion,} a process
    absent in the standard fluid equations."

    example_text = example_text + "\\\\ \n "

    example_text = example_text + wrap_image('figures/kh-1.png', 8, 'r')

    example_text = example_text + "From a fluid dynamics standpoint,
    when you stir cream into your coffee, all you’re doing is folding
    and stretching the different layers of fluid into thinner and
    thinner sheets\\ldots once the sheets get microscopically thin, the
    fluid equations break down, diffusion takes over, and you finally
    mix the two liquids."

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "Most astrophysical simulations omit
    diffusion entirely, so when we see ``mixing,\'\' it's  due to
    \\textbf{numerical errors}.  This raises an unsettling question:
    \\textit{are the beautiful structures in high-resolution
    simulations real---or artifacts?}"

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.96],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)


    t.show_text('text'          => section_fmt('The Kelvin-Helmholtz Instability'),
                'at'            => [0.98, 0.585],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 0*atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)


    example_text = wrap_image('figures/kelvin-highres.png', height=8, alignment='l', width_fact=1.5)

    example_text = example_text + "The
    \\textbf{\\textit{Kelvin–Helmholtz instability}} (KH) arises when
    two fluid layers slide past each other.  It produces iconic
    rolling billows—seen in the sky, in oceans, and in countless
    simulation papers."

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "As resolution increases, KH
    simulations often reveal intricate \\textit{swirls-within-swirls,}
    which are widely assumed to indicate numerical accuracy and
    turbulence."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.345],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)


    t.show_text('text'          => section_fmt('Do These Swirls Converge?'),
                'at'            => [0.98, 0.285],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 0*atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = wrap_image('figures/kelvin-highres-late.png', height=10, alignment='r', width_fact=1.75)

    example_text = example_text + "We investigated whether these simulations actually
    \\textit{converge} to a well-defined solution.  The result:
    \\textbf{they don't}.  Simulations with increasing resolution
    produce \\textbf{\\textit{different answers, not better
    ones}}---more swirls, more chaos, more discrepancy."

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "You can often guess the
    simulation's resolution by counting how many layers of swirls it
    has."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.0],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)

    # grid
  end

  def second_col
    # saturation plot
    t.show_text('text'          => section_fmt('A Modified, Solvable Problem'),
                'at'            => [0.98, 1.01],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = "We designed a slightly altered version of the KH
    problem---one that includes a small but controlled amount of
    diffusion.  This version has a well-defined solution, allowing us
    to test convergence rigorously."

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "The result was striking:
    \\textbf{the true solution has no such tiny swirls}. "

    #example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "Even more surprising, the tiny
    swirls are present in lower resolution, un-converged simulations,
    but \\textbf{disappear as we approach convergence!}"

    example_text = example_text + "\\\\ \n "

    example_text = example_text + image('figures/drat-early.png', 0.8)

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.98, 0.95],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)


    t.show_text('text'          => section_fmt('Implications for Simulation Practice'),
                'at'            => [0.98, 0.55],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => 0*atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = wrap_image('figures/nodiff.png', height=20, alignment='l', width_fact=0.5)

    example_text = example_text + "Astronomers often neglect diffusion
    from their simulations because the true, physical scale for
    diffusion is impossible to resolve.  We think that, by setting
    diffusion to zero in our codes, we get the least amount of
    diffusion.  However, this is not the case!"

    example_text = example_text + "\\\\*[2ex] \n "

    example_text = example_text + "Without any diffusion, the smallest
    perturbations grow unchecked, generating swirls from
    \\textit{numerical noise, not physics}.  Including
    diffusion---even at unrealistically high levels---\\textbf{reduces
    unphysical mixing} and produces more reliable results,
    \\textit{with \\textbf{less} mixing}. "

    example_text = example_text + "\\\\*[1.5ex] \n "

    example_text = example_text + "It\'s better to have a controlled
    approximation than uncontrolled chaos."

    example_text = example_text + "\\\\*[1.5ex] \n "

    example_text = example_text + "\\textbf{What\'s next?}  We\'re developing
    benchmark tests and convergence criteria for mixing in
    astrophysical simulations."

    example_text = example_text + "\\\\*[1.5ex] \n "

    example_text = example_text +
    "This work cautions against interpreting small-scale structures as
    signs of realism.  \\textbf{Sometimes, a prettier picture is a
    numerical mirage.}  "

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.49],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)


    # grid
  end


end

MyPlots.new


# Local Variables:
#   compile-command: "tioga buoyancy-saturation.rb -s"
# End:
