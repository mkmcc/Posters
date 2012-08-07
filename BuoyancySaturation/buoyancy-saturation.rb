# poster.rb: make a poster.
#
# Time-stamp: <2012-08-07 08:42:14 (mkmccjr)>
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

    t.def_figure('buoyancy-saturation') { make_poster }
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
    ncols = 3.0
    size  = (1.0 - (ncols-1)*@hsep)/ncols
    skip  = size + @hsep

    mk_col(0*skip, 2*skip){ first_col  }
    mk_col(1*skip, 1*skip){ second_col }
    mk_col(2*skip, 0*skip){ last_col }
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

    title = title_fmt('{\color{black} \ornament{8}} Do Galaxy Clusters Boil?')

    t.show_text('text'          => title,
                'at'            => [0.0, 0.9],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED,
                'color'         => @title_text_color)

    authors = 'Mike McCourt, Ian Parrish, Prateek Sharma, \& Eliot Quataert'
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

    t.show_text('text'          => '\textcopyright\ authors 2012',
                'at'            => [0.005, 0.1],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text'          => '\fontsize{20}{20}\selectfont\textbf{References}',
                'at'            => [0.995, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @title_text_color)

    refs = '\textbf{McCourt et al. (2010)}, Sharma et al. (2009),
             Quataert (2008), Parrish \& Quatert (2008), Parrish \&
             Stone (2005, 2007), Balbus (2000)'

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

    text = '\includegraphics[width=' + physical_width.to_s \
           + 'in]{'+file+'}'

    text
  end

  # Make a square wrapfig of size height lines
  #
  def wrap_image(file, height, alignment="l")
    text = "\\includegraphics[height=#{(height-0.5).to_s}\\baselineskip]{#{file}}"

    text = "\\begin{wrapfigure}[#{height.to_s}]{#{alignment}}{#{(height-0.7).to_s}\\baselineskip}
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

    example_text = wrap_image('plots/HydraAoptical', 10) +
    "\\textsc{Galaxy clusters} are the largest gravitationally bound
    objects in the universe.  Clusters contain the most massive
    galaxies and the most massive black holes, and may provide useful
    constraints on dark energy.  \\\\*[2ex] \n Clusters are mostly
    dark matter by mass, but the baryons play a surprisingly important
    role in their evolution.  Moreover, the baryons are all that we
    can observe.  Understanding the evolution of the baryons is thus
    essential to improving our understanding of clusters."

    example_text = example_text + "\\\\*[2ex] \n\n" \
    +wrap_image('plots/HydraAxray', 10, 'r') + "Most of the baryons in
    clusters ($\\sim80\\%$) comprise a hot, dilute plasma known as the
    intracluster medium.  Much about the thermal evolution of the ICM
    remains unclear.  For example, it has only recently been
    discovered that the ICM is \\textit{convectively unstable at all
    radii}.  This instability is known as the HBI (MTI) when the
    temperature increases (decreases) with radius."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.95],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text' => caption_fmt("stars (optical)"),
                'at' => [0.04, 0.94],
                'color' => LightGray,
                'justification' => LEFT_JUSTIFIED,
                'alignment' => ALIGNED_AT_TOP)


    t.show_text('text' => caption_fmt("hot gas (xray)"),
                'at' => [0.96, 0.52],
                'color' => LightGray,
                'justification' => RIGHT_JUSTIFIED,
                'alignment' => ALIGNED_AT_TOP)


    # Method
    t.show_text('text'          => section_fmt('Method'),
                'at'            => [0.98, 0.2],
                'alignment'     => ALIGNED_AT_BASELINE,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color)

    example_text = "We use the MHD code \\textsf{Athena}, modified to
    implement anisotropic thermal conduction: $Q_{\\mathrm{cond}} = -
    \\kappa \\hat{b} (\\hat{b}\\cdot\\nabla T)$. \\\\*[2ex] \n The
    conductivity takes this form because the electron mean free path
    in the ICM is much longer than its gyroradius.  The electrons
    (which transport most of the energy) are thus confined to move
    along magnetic field lines."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.0],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)

    # grid
  end

  def second_col
    # saturation plot
    t.show_text('text'          => section_fmt('Physics of the HBI \& MTI'),
                'at'            => [0.98, 1.01],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = "\\textsc{The hbi and mti} are convective
    instabilities driven by \\textit{anisotropic} thermal conduction
    in plasmas.  Electrons move freely along magnetic field lines,
    redistribute energy and buoyantly destabilize vertically displaced
    fluid elements.  Perturbations grow with the local dynamical time
    $t_{\\mathrm{HBI}} \\sim t_{\\mathrm{dyn}} \\sim
    \\sqrt{H/g}$. \\\\*[2ex] \n {\\footnotesize (color shows the
    plasma temperature and lines trace the magnetic field.)}
    \\\\*[2ex] \n"

    example_text = wrap_image('plots/buoyancy_schematic', 10) + example_text

    example_text = example_text + image('plots/hbi_5panel', 0.96)

    example_text = example_text + "\\\\*[2ex] \n The HBI saturates
    quiescently by reorienting the magnetic field lines.  This
    insulates the plasma against a conductive heat flux, and may
    exascerbate the cooling flow problem. \\\\*[2ex] \n"

    example_text = example_text + image('plots/mti_5panel_h', 0.96)

    example_text = example_text + "\\\\*[2ex] \n Though the linear
    behavior of the MTI is similar to that of the HBI, its nonlinear
    behavior is entirely different.  The MTI does not reorient the
    field lines and in fact drives strong, $\\sim$~sonic turbulence."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.98, 0.95],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)

    # t.show_text('text'          => image('plots/mti_5panel_v', 0.5),
    #             'at'            => [0.02, 0.0],
    #             'alignment'     => ALIGNED_AT_BOTTOM,
    #             'justification' => LEFT_JUSTIFIED)

    # example_text = "\\footnotesize The MTI generates turbulence even if
    # the magnetic field lines are initially vertical -- though this
    # state is linearly stable, it is nonlinearly unstable."

    # t.show_text('text' => minipage(example_text, 0.45),
    #             'at' => [0.98, 0.0],
    #             'alignment' => ALIGNED_AT_BOTTOM,
    #             'justification' => RIGHT_JUSTIFIED)

    # grid
  end

  def last_col
    t.show_text('text'          => section_fmt('Implications for Clusters'),
                'at'            => [0.98, 1.01],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color,
                'angle' => atan(2*@top_tilt*@head_height) * 180/3.1416 * 0.5)

    example_text = wrap_image('plots/ClusterSim', 10) + "The MTI may
    be an important source of turbulence at large radii in galaxy
    clusters.  This influences both the strength of the magnetic field
    and the mixing of metals in the ICM.  More importantly, MTI
    turbulence may introduce a \\textit{systematic, 5--10\\% bias}
    into cluster mass estimates. \\\\ \n \\textbf{Understanding this
    bias may be crucial for using clusters for precision cosmology.}"

    example_text = example_text + "\\\\*[2ex] \n" \
    + wrap_image('plots/temperature_panel', 10, 'r')

    example_text = example_text + "\n The HBI tends to make the
    magnetic field horizontal, while other sources of turbulence tend
    to isotropize it.  These effects compete and control the mean
    orientation of the magnetic field $\\hat{b}_z \\propto
    (t_{\\mathrm{eddy}} / t_{\\mathrm{HBI}})^2$.  The field angle, in
    turn, sets the effective thermal conductivity of the plasma, thus
    controlling an important source of energy to offset cooling in the
    ICM.  \\textbf{ Understanding the interaction between turbulence
    and the HBI, particularly in a cooling plasma, is crucial for
    understanding the thermodynamics of the plasma at small radii in
    clusters.}"

   t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.5, 0.95],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => CENTERED)

    rgb = @section_text_color.join(",")
    example_text = "\\definecolor{mytempcolor}{rgb}{#{rgb}}
    \\textbf{\\Large \\color{mytempcolor} Acknowledgments}
    \\\\*[1.25ex] \\footnotesize E.~Q., I.~P., and M.~M. were
    partially supported by \\textsc{nasa atp} grant
    \\textsc{nnx10ac95g} and Chandra theory grant
    \\textsc{tm2-13004x}.  We have benefited from the open source
    projects \\textsc{Athena} and \\textsc{Tioga}, as well as NASA's
    Astrophysics Data System."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.00],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text' => '\Huge \ornament{6}',
                'at' => [0.5, 0.175],
                'alignment' => ALIGNED_AT_MIDHEIGHT,
                'justification' => CENTERED)

    # grid
  end

end

MyPlots.new


# Local Variables:
#   compile-command: "tioga buoyancy-saturation.rb -s"
# End:
