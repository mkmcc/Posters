# poster.rb: make a poster.
#
# Time-stamp: <2025-04-12 15:38:15 (mkmcc)>
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
    "\n\t\\usepackage[osf]{mathpazo}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{amsmath,amssymb,paralist}\n"

    t.tex_preview_preamble += \
    "\n\t\\usepackage{ChaparralPro}\n"

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
    @body_text_color         = Black # @base0
    @section_text_color = @blue.map{|c| 0.75 * c}

    rgb = @body_text_color.join(",")
    t.tex_preview_preamble += "\n\t\\definecolor{mytext}{rgb}{#{rgb}}\n"
    t.tex_preview_preamble += "\n\t\\color{mytext}\n"

    t.def_figure('thermal-instability') { make_poster }
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
    ncols = 4.0
    size  = (1.0 - (ncols-1)*@hsep)/ncols
    skip  = size + @hsep

    mk_col(0*skip, 3*skip){ first_col  }
    mk_col(1*skip, 2*skip){ second_col }
    mk_col(2*skip, 1*skip){ third_col }
    mk_col(3*skip, 0*skip){ last_col   }
  end

  def section_fmt(text)
    '\fontsize{16}{16}\selectfont\textbf{' + text + '}'
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

    title = title_fmt('Thermal Instability in Hot Halos')

    t.show_text('text'          => title,
                'at'            => [0.025, 0.9],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED,
                'color'         => @title_text_color)

    authors = 'Mike McCourt, Prateek Sharma, Eliot Quataert, \& Ian Parrish'
    authors = author_fmt(authors)

    t.show_text('text'          => authors,
                'at'            => [0.05, 0.05],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED,
                'color'         => @author_text_color)

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

    refs = 'McCourt et al. (2012), Sharma et al. (2012a,b), \
           Sharma et al. (2010)'
    t.show_text('text'          => author_fmt(refs),
                'at'            => [0.995, 0.5],
                'alignment'     => ALIGNED_AT_TOP,
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
  def wrap_image(file, height)
    text = "\\includegraphics[height=#{(height-0.5).to_s}\\baselineskip]{#{file}}"

    text = "\\begin{wrapfigure}[#{height.to_s}]{l}{#{(height-0.7).to_s}\\baselineskip}
           \\vspace{-\\baselineskip}%
           #{text}
           \\end{wrapfigure} \n"

    text
  end


  ##############################################################################
  ### Content
  def first_col
    t.show_text('text'          => section_fmt('Introduction'),
                'at'            => [0.98, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color)

    example_text = "\\textsc{Some galaxy clusters} contain long, thin
    \\textbf{\\textit{filaments of cold gas}} embedded in an otherwise hot
    plasma---a surprising phenomenon, since cold gas should quickly
    heat up and evaporate."

    example_text = example_text + "\\\\*[2ex] \n" + "We explore how
    \\textbf{\\textit{thermal instability}}---a runaway cooling
    process---can generate and sustain these cold structures within
    hot halos.  Crucially, we find that this process only occurs in
    regions where \\textbf{\\textit{cooling beats gravity:}} the
    instability develops only when the \\textit{cooling time drops
    below the free-fall time}, or when $t_{\\mathrm{cool}} /
    t_{\\mathrm{ff}} \\lesssim 10$."

    example_text = example_text + "\\\\*[2ex] \n" + "This threshold
    not only explains when and where cold gas forms, but may also
    \\textbf{regulate feedback} from black holes in cluster
    centers---helping to control the structure and evolution of massive
    galaxies."

    example_text = minipage(example_text, 0.96)

    t.show_text('at'            => [0.02, 0.95],
                'text'          => example_text,
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)



    t.show_text('text'          => section_fmt('Overview'),
                'at'            => [0.98, 0.5],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color)

    example_text = "\\begin{itemize} \n \\item Assuming that the ICM
    in galaxy groups and clusters is globally stabilized by heating,
    it is \\textit{locally thermally unstable}.  This is true even if
    thermal conduction is rapid.  \n \\item The non-linear saturation
    of thermal instability is controlled by the ratio of the cooling
    time to the free-fall time.  The instability produces multi-phase
    gas only when $t_{\\mathrm{cool}}/t_{\\mathrm{ff}}\\lesssim 10$ \n
    \\item If thermal instability powers AGN feedback, halos should
    self-regulate to the critical threshold for non-linear stability:
    $t_{\\mathrm{cool}}/t_{\\mathrm{ff}}\\sim 10$.  In practice, this
    introduces a density ``core'' and explains the observed deviations
    from gravitational self-similarity \\end{itemize}"

    example_text = "\\renewcommand{\\labelitemi}{\\ornament{24}}"\
    +minipage(example_text, 0.96)

    t.show_text('text'          => example_text,
                'at'            => [0.02, 0.0],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)

    # grid
  end

  def second_col
    # saturation plot
    t.show_text('text'          => section_fmt('Non-Linear Saturation'),
                'at'            => [0.98, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color)

    example_text = wrap_image('plots/saturation-plot', 7) \
    +"\\textsc{This figure} illustrates the full development of
    thermal instability.  The perturbations initially grow
    exponentially, but saturate at an amplitude which depends on the
    ratio of the cooling time to the free-fall time
    $t_{\\mathrm{cool}}/t_{\\mathrm{ff}}$.  This amplitude can be > 1
    or < 1.  Thus, \\textbf{\\textit{linear thermal instability need
    not produce multi-phase gas}}. \\\\*[2ex] \n Intuitively, the
    instability stops when the infall time for an over-dense blob
    approaches its cooling time---shear instabilities then develop on
    a competitive timescale with thermal instability and can mix the
    gas.  This competition sets the amplitude of the density
    perturbations. "

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.98, 0.95],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)



    # ACCEPT data
    rgb = @section_text_color.join(",")
    example_text = "{\\color{mytempcolor} Comparison with \\textsc{Accept} Data}"
    example_text = section_fmt("\\raggedleft #{example_text} \\par")
    example_text = minipage(example_text, 0.7)

    example_text = "\\definecolor{mytempcolor}{rgb}{#{rgb}} " + example_text


    t.show_text('text'          => example_text,
                'at'            => [0.98, 0.5],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)

    t.show_text('text'          => image('plots/cluster-plot', 0.96),
                'at'            => [0.5, 0.41],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => CENTERED)


    example_text = "\\textsc{Consistent with our model}, clusters in
    the \\textsc{accept} catalog only show multi-phase gas below a
    threshold in $t_{\\mathrm{cool}}/t_{\\mathrm{ff}}$.  Moreover,
    most multiphase gas is located within $\\sim$10--20\\,kpc, where
    this ratio reaches a minimum.\\\\[2ex] \n \\textbf{\\textit{The
    ratio t$_{\\mathrm{\\textbf{\\footnotesize
    cool}}}$/t$_{\\mathrm{\\textbf{\\footnotesize ff}}}$ is a better
    predictor of multi-phase gas than
    t$_{\\mathrm{\\textbf{\\footnotesize cool}}}$ alone}}."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.98, 0.0],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => RIGHT_JUSTIFIED)

    # grid
  end

  def third_col
    # saturation plot
    t.show_text('text'          => section_fmt('Feedback Regulation'),
                'at'            => [0.98, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'         => @section_text_color)

    example_text = "\\textsc{Thermal Instability} may power AGN
    feedback in galaxy groups and clusters.  Since the accretion rate
    from infalling clumps can vastly exceed accretion from the hot
    phase, the onset of thermal instability triggers powerful heating
    episodes.  \\textbf{\\textit{Our simulated halos self-regulate to
    the critical threshold for thermal instability, with
    t$_{\\mathrm{\\textbf{\\footnotesize
    cool}}}$/t$_{\\mathrm{\\textbf{\\footnotesize ff}}}$ $\\sim$
    10.}} \\\\ \n\n"

    example_text = example_text + wrap_image('plots/feedback-regulation', 7)

    example_text = example_text + "In this simulation, ther\\-mal
    instability devel\\-ops du\\-ring the first Gyr and produces
    clumps of cool gas.  When the clumps reach the center of the halo
    around 2\\,Gyr, they trigger feedback and heat the gas above the
    threshold for non-linear stability.  This removes the fuel source
    for AGN heating and the gas settles into a quasi-equilibrium."

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.95],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)




    # non-self-similarity
    example_text = section_fmt("Breaking Self-Similarity")
    example_text = section_fmt(example_text)
    t.show_text('text'          => example_text,
                'at'            => [0.98, 0.4],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'color'          => @section_text_color)

    example_text = "\\textsc{The threshold} for non-linear thermal
    stability thus limits the density of the gas below the prediction
    of gravitational self-similarity.  \\textbf{\\textit{Our criterion
    correctly predicts the ``excess\'\' entropy observed in groups and
    low-mass clusters, as well as the observational
    luminosity--temperature relation.}}"

    t.show_text('text'          => minipage(example_text, 0.96),
                'at'            => [0.02, 0.0],
                'alignment'     => ALIGNED_AT_BOTTOM,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text'          => image('plots/density-core',0.4),
                'at'            => [0.02, 0.35],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => LEFT_JUSTIFIED)

    t.show_text('text'          => image('plots/lxvt',0.4),
                'at'            => [0.98, 0.35],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED)

    # Grid
  end

  def last_col
    t.show_text('text'          => section_fmt('What About Conduction?'),
                'at'            => [0.98, 1.0],
                'alignment'     => ALIGNED_AT_TOP,
                'justification' => RIGHT_JUSTIFIED,
                'angle' => 0.0 * atan(2*@top_tilt*@head_height) * 180/3.14159,
                'color'         => @section_text_color)

    example_text = "\\textsc{Of course}, conduction can suppress
    thermal instability on small scales.  Crucially, however, thermal
    conduction in clusters is \\textit{anisotropic:} since electrons
    cannot cross magnetic field lines, they only transport energy in
    the direction of the field.  \\\\*[2ex] \n The figure below
    compares simulations with different values of the conductivity and
    shows that thermal instability is not suppressed in the direction
    perpendicular to the magnetic field.  \\\\*[2ex] \n" \
    + image('plots/compare-conduction-small',0.96) + "\\\\*[2ex]"\
    + "Although conduction significantly changes the
    \\textit{morphology} of the thermally unstable gas (clumps $\\to$
    filaments), in practice it has little effect on the mass in the
    cold phase.  \\\\*[2ex] \n"

    example_text = example_text \
    + wrap_image('plots/cold-fraction-conduction', 5)

    example_text = example_text + "Thus, anisotropic conduction is
    \\textit{very different} from isotropic conduction, which readily
    suppresses thermal instability.  This figure compares simulations
    with isotropic and anisotropic conduction."

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

    # grid
  end

end

MyPlots.new


# Local Variables:
#   compile-command: "tioga thermal-instability.rb -s"
# End:
