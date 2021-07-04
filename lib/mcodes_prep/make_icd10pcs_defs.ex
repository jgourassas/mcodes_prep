defmodule McodesPrep.MakeIcd10pcsDefs do
  import SweetXml
  require Ecto.Query
  require Logger
  import McodesPrep.Utils

  def set_pcs_defs_xml_file do
    IO.gets("\t Location of ICD10-PCS DEFINITIONS XML file i.e: data/icd10pcs_definitions_2022.xml
    > ") |> String.trim()
  end

  ########################
  def pcs_defs_xml_file do
    pcs_defs_file = set_pcs_defs_xml_file()
    file_existance(pcs_defs_file)
  end

  ######################
  def pcs_defs_xml_list do
    pcs_defs_xml_file()
    |> xpath(
      ~x"//section"l,
      section: ~x"./@code"so,
      section_title: ~x"./title/text()"so,
      axis_l: [
        ~x".//axis"l,
        axis_code: ~x"./@pos"so,
        axis_title: ~x"./title/text()"so,
        terms_l: [
          ~x".//terms"lo,
          term_titles_l: [
            ~x".//title"l,
            term_title: ~x"./text()"so
          ],

          # term_titles
          term_definition: ~x"./definition/text()"so,
          term_explanation: ~x"./explanation/text()"so,
          term_includes_l: [
            ~x".//includes"l,
            term_include: ~x"./text()"so
          ]

          ## term_includes
        ]

        # terms_l
      ]

      # axis_l
    )
  end

  # xml_list
  ########################
  def make_pcs_defs do
    colorize_text("default", "Im nearly Ready to Make icd10pcs_defs table")

    response = ask_user()

    case response do
      "Y" ->
        pcs_defs_as_list = pcs_defs_xml_list()
        Enum.each(pcs_defs_as_list, fn a_map -> insert_icd10pcs_defs(a_map) end)
        colorize_text("default", "Ok Thx ")

      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")

      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end
  end

  # make_pcs_defs
  #######################
  def insert_icd10pcs_defs(map) do
    axis_l = map[:axis_l]
    section = map[:section]
    section_title = map[:section_title]

    Enum.each(axis_l, fn l ->
      axis_code = l[:axis_code]
      axis_title = l[:axis_title]
      terms_l = l[:terms_l]

      Enum.each(terms_l, fn term_l ->
        term_titles_l = term_l[:term_titles_l]

        term_titles =
          Enum.reduce(term_titles_l, " ", fn x, acc ->
            %{term_title: v} = x
            acc <> "^" <> v
          end)

        term_includes_l = term_l[:term_includes_l]

        term_includes =
          Enum.reduce(term_includes_l, " ", fn x, acc ->
            %{term_include: v} = x
            acc <> "^" <> v
          end)

        term_definition = term_l[:term_definition]
        term_explanation = term_l[:term_explanation]
        colorize_text("default", "#{section_title}")
        # {:ok, inserted} =
        McodesPrep.Repo.insert(%McodesPrep.Icd10pcsDefs{
          section: section,
          section_title: section_title,
          axis_code: axis_code,
          axis_title: axis_title,
          term_titles: term_titles,
          term_includes: term_includes,
          term_definition: term_definition,
          term_explanation: term_explanation,
          terms: term_l
        })
      end)

      colorize_text("alert", "---Finish -------------------------")
    end)
  end

  # insert_icd10pcs_defs
  #####################
  def search_pcs_defs do
    print_searching_in("Search ICD-10-PCS DEFINITIONS File")
    main_term_field = get_response("Type a term as: Change, Replacement, Alteration ")

    main_term_q =
      Ecto.Query.from(p in McodesPrep.Icd10pcsDefs,
        order_by: [asc: p.term_titles],
        where: fragment("(?) @@ plainto_tsquery(?)", p.term_titles, ^"#{main_term_field}%"),
        select: %{
          terms: fragment("? ", p.terms),
          section_title: fragment(" ? ", p.section_title),
          section: fragment(" ? ", p.section)
        },
        limit: 10
      )

    records_b = main_term_q |> McodesPrep.Repo.all()

    if Enum.any?(records_b) do
      IO.puts(" ")
      print_results_title(main_term_field)
      IO.puts(" ")

      Enum.map(records_b, fn rec ->
        terms_rec = rec[:terms]
        section = rec[:section]
        section_title = rec[:section_title]

        format_record(terms_rec)
        print_element(section, "Section: " <> section_title)

        IO.puts(" ")
      end)
    else
      colorize_text("alert", "Nothing Found")
    end

    response =
      get_response("Search Again in ICD-10-PCS Definitions File? [Y,N]") |> String.upcase()

    case response do
      "Y" ->
        search_pcs_defs()

      "N" ->
        colorize_text("default", "Ok. help for options, q to Quit")

      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end
  end

  ###############
  def format_record(map) do
    term_titles_l = map["term_titles_l"]

    for title <- term_titles_l do
      title = title["term_title"]

      IO.puts(
        IO.ANSI.blue_background() <>
          IO.ANSI.white() <> " ❄❄❄ Term Title: #{title} ❄❄❄ " <> IO.ANSI.reset()
      )
    end

    term_definition = map["term_definition"]
    print_element(term_definition, "Definition")

    term_explanation = map["term_explanation"]
    print_element(term_explanation, "Explanation")

    term_includes_l = map["term_includes_l"]

    for include <- term_includes_l do
      include = include["term_include"]
      print_element(include, "Include")
    end
  end

  ########################
end

## module
