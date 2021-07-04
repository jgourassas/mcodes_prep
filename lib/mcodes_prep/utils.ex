defmodule McodesPrep.Utils do
  alias TableRex.Table

  def ask_user do
    IO.gets(
      IO.ANSI.blue() <>
        "\t \u25B6\u25B6" <>
        "May Procced? [Y,N] " <>
        IO.ANSI.default_color()
    )
    |> String.trim()
    |> String.upcase()
  end

  def get_response(query) do
    _response =
      IO.gets("\t " <> IO.ANSI.default_color() <> "#{query} >  " <> IO.ANSI.default_color())
      |> String.trim()
      |> String.upcase()
  end

  ###############################
  def colorize_text(flag, text) do
    case flag do
      "warn" ->
        [:orange, " #{text} "]
        |> Bunt.puts()

      "info" ->
        [:cyan, " #{text} "]
        |> Bunt.puts()

        "info_2" ->
          [:gold, " #{text} "]
          |> Bunt.puts()

      "nofound" ->
        [:red, "  #{text} "]
        |> Bunt.puts()

      "alert" ->
        [:red, " #{text} "]
        |> Bunt.puts()

      # "default" ->
      #  [:black,  "\t #{text} "]
      #  |> Bunt.puts

      "default" ->
        [:black, " #{text} "]
        |> Bunt.puts()

      "default_write" ->
        [:black, " #{text} "]
        |> Bunt.write()

      "success" ->
        [:darkgreen, " #{text} "]
        |> Bunt.puts()

      "success_write" ->
        [:darkgreen, " #{text} "]
        |> Bunt.write()

      "main_term" ->
        [:color243, " #{text} "]
        |> Bunt.puts()

      "dash" ->
        [:color27, " #{text} "]
        |> Bunt.puts()

      "main_term_write" ->
        [:black, " #{text} "]
        |> Bunt.write()

      _ ->
        [:red, "  #{text}  "]
        |> Bunt.puts()
    end
  end

  #######################

  ### ===================================
  ### File icd10pcs_order_YYYY.txt
  ### Position Lenght      Representation
  ### -------------------------------------
  ### 1         5          Order Number
  ### 6         1          Blank
  ### 7         7          PCS code Dots are not Included
  ### 14        1          Blank
  ### 15        1          0 is Header not valid for submission, 1 Ok
  ### 16        1          Blank
  ### 17        60         Short Description
  ### 77        1          Blank
  ### 78        Up to 300  Long Description
  ### Source
  ### https://www.nlm.nih.gov/research/umls/sourcereleasedocs/
  ###  current/ICD10PCS/sourcerepresentation.html
  ########################
  def slice_line_orders(line) do
    order_number =
      String.slice(line, 0..5)
      |> String.trim_trailing()

    icd10cm_code =
      String.slice(line, 6..13)
      |> String.trim_trailing()

    is_header =
      String.slice(line, 14..15)
      |> String.trim_trailing()

    short_description =
      String.slice(line, 16..76)
      |> String.trim_trailing()

    ## it may be 77..300
    long_description =
      String.slice(line, 77..250)
      |> String.trim_trailing()

    _new_line =
      order_number <>
        "^" <>
        icd10cm_code <>
        "^" <>
        is_header <>
        "^" <>
        short_description <>
        "^" <>
        long_description <>
        "\n"
  end

  #################
  def file_existance(file) do
    exists = File.exists?(file)

    case exists do
      true ->
        colorize_text("info", " Thx. File was found and Loaded. ")
        File.stream!(file)

      false ->
        colorize_text("nofound", "--- Sorry File Not Found  ---")
        McodesPrep.Cli.loop()

      _ ->
        colorize_text("nofound", "No Input text")
    end
  end

  ###############################
  #######################

  ### ===================================
  ### File icd10pcs_order_YYYY.txt
  ### Position Lenght      Representation
  ### -------------------------------------
  ### 1         5          Order Number
  ### 6         1          Blank
  ### 7         7          PCS code Dots are not Included
  ### 14        1          Blank
  ### 15        1          0 is Header not valid for submission, 1 Ok
  ### 16        1          Blank
  ### 17        60         Short Description
  ### 77        1          Blank
  ### 78        Up to 300  Long Description
  ### Source
  ### https://www.nlm.nih.gov/research/umls/sourcereleasedocs/
  ###  current/ICD10PCS/sourcerepresentation.html
  ########################
  def slice_line_orders1(line) do
    order_number =
      String.slice(line, 0..5)
      |> String.trim_trailing()

    icd10_code =
      String.slice(line, 6..13)
      |> String.trim_trailing()

    is_header =
      String.slice(line, 14..15)
      |> String.trim_trailing()

    short_description =
      String.slice(line, 16..76)
      |> String.trim_trailing()

    ## it may be 77..300
    long_description =
      String.slice(line, 77..250)
      |> String.trim_trailing()

    _new_line =
      order_number <>
        "^" <>
        icd10_code <>
        "^" <>
        is_header <>
        "^" <>
        short_description <>
        "^" <>
        long_description <>
        "\n"
  end

  #######################
  def level_intend(term_level) do
    _intend =
      case term_level do
        "1" ->
          # IO.ANSI.cyan()  <> "-"  <> IO.ANSI.reset# it breaks the TableRe
          # is ok bold arrow
          "\u27A4"

        # "\u2714"
        # "-"
        "2" ->
          "--"

        "3" ->
          "---"

        "4" ->
          "----"

        "5" ->
          "-----"

        "6" ->
          "------"

        "7" ->
          "-------"

        _ ->
          "\t"
      end

    ##################
  end

  ## level_intend

  ########################
  def inspect_data(data) do
    IO.inspect(data,
      limit: :infinity,
      pretty: true,
      syntax_colors: [number: :red, atom: :blue, tuple: :blue, map: :blue, list: :green],
      width: 0
    )
  end

  def present_tablerex(records, header, title) do
    Table.new(records, header, title)
    |> Table.put_header_meta(0..2, color: IO.ANSI.color(31))
    # `0` is the column index.
    |> Table.put_column_meta(0, align: :left, padding: 5)
    |> Table.put_column_meta(2,
      color: fn text, value -> if value in ["1"], do: [:green, text], else: [:red, text] end
    )
    # sets column header to red, too
    |> Table.put_column_meta(0, color: :blue)
    # `1..2` is a range of column indexes. :all also works.
    |> Table.put_column_meta(1..2, align: :left)
    |> Table.render!(
      horizontal_style: :all,
      top_frame_symbol: "*",
      header_separator_symbol: "=",
      horizontal_symbol: "~",
      vertical_symbol: "!"
    )
    |> IO.puts()
  end

  #####################
  def print_element(data, title) when data == nil do
    ""
  end

  def print_element(data, title) when data == "" do
    ""
  end

  def print_element(data, title) do
    carret_replacment = IO.ANSI.red() <> " \u25AE" <> IO.ANSI.default_color() <> ""
    an_element = String.replace(data, "^", carret_replacment)

    colorize_text(
      "default",
      IO.ANSI.italic() <>
        IO.ANSI.blue() <>
        "▶▶" <>
        "#{title}" <>
        IO.ANSI.default_color() <>
        IO.ANSI.not_italic() <>
        ": " <>
        "#{an_element}" <>
        " \n"
    )
  end

  #####################
  def print_searching_in(title) do
    IO.puts(" ")

    IO.puts(
      IO.ANSI.black_background() <>
        IO.ANSI.white() <>
        " \u25A3 \u0391\u03A9 ---------- \u2766  #{title} \u2766 ---------- \u25A3 " <>
        IO.ANSI.reset()
    )

    IO.puts(" ")
  end

  def say_message(title) do
    IO.puts(" ")

    IO.puts(
      IO.ANSI.black_background() <>
        IO.ANSI.white() <>
        " \u2766 #{title} \u2766 " <> IO.ANSI.reset()
    )
  end

  ##################
  def print_results_title(title) do
    IO.puts(" ")

    IO.puts(
      IO.ANSI.black_background() <>
        IO.ANSI.white() <>
        " \u25A3 \u0391\u03A9 ---------- \u25C9  Results For: #{title} \u25C9 ---------- \u25A3 " <>
        IO.ANSI.reset()
    )

    IO.puts(" ")
  end

  ############
end

## module
