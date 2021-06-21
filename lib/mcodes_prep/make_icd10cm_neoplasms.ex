defmodule McodesPrep.MakeIcd10cmNeoplasms do
  import  SweetXml
  require Ecto.Query
  require  TableRex
  require Logger
  import  McodesPrep.Utils
  alias   McodesPrep.Utils, as: Utils

  def set_neoplasm_xml_file do
    IO.gets("\t Location of ICD-10-CM INDEX XML file i.e: data/icd10cm_neoplasm_2022.xml  > ")  |> String.trim
  end
  ########################
  def neoplasm_xml_file  do
    neoplasm_file = set_neoplasm_xml_file()
    file_existance(neoplasm_file)
  end
  #################

  def neoplasm_xml_list do
    neoplasm_xml_file() |> xpath(
      ~x[//letter]l,
      letter_title: ~x"./title/text()"s,
      main_terms_l: [
        ~x".//mainTerm"l,
        main_title: ~x"./title/text()"s,
        main_cell_l: [
          ~x".//cell"l,
          main_cell_col: ~x"./@col"so,
          main_cell_code: ~x"./text()"so
        ], #main_cell_l
        terms_l: [
          ~x"//term"l,
          term: [
            ~x"//term[@level=\"1\"]/descendant-or-self::*[@level]"l,
            term_level: ~x"./@level"so,
            term_title: ~x"./title/text()"so,
            term_nemod: ~x"./title/nemod/text()"so,
            term_see: ~x"./see/text()"so,
            term_see_also: ~x"./seeAlso/text()"so,
            term_cell_l: [
              ~x"./cell"l,
              cell_col: ~x"./@col"so,
              cell_code: ~x"./text()"so

            ] #term_cell
          ] #term
        ] #terms_l

      ] ##main_term_l
    )
  end
######################
  defp insert_neoplasm(map) do
    main_terms_l = map[:main_terms_l]

    Enum.map(main_terms_l, fn(l) ->
      terms_l = l[:terms_l]

      Enum.map(terms_l, fn(a_term) ->
        term = a_term[:term]

        for elm <- term   do
          cond do
            value = Map.get(elm, :term_level) ->
              if value == "1" do
                term_title = elm[:term_title]
                colorize_text("default", "Inserting Title: " <> "#{term_title}")
                terms_map =   term |> Iteraptor.to_flatmap

                McodesPrep.Repo.insert(%McodesPrep.Icd10cmNeoplasms{title: term_title, main_term: terms_map})
              end#if
            true ->
              IO.puts "No value"
          end #cond
        end# for

      end) #terms_l
    end)
  end

  ########################
  def make_neoplasm do
    colorize_text("default", "Make icd10cm_neoplasms PG tables?")

    response = ask_user()
    case response do
      "Y" ->
        colorize_text("default", "Question: ")
        neoplasm_as_list = neoplasm_xml_list()
        Enum.each(neoplasm_as_list, fn a_map ->  insert_neoplasm(a_map) end)
        colorize_text("default", "Ok Thx ")

      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")

      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end


  end#make_pcs_index
  #######################
  def search_cm_neoplasms()  do
    print_searching_in("Search ICD-10-CM Neoplasms File")
    main_term_field = get_response("Type a term as:  endocardium,  esophagus " )
    main_term_q =
      Ecto.Query.from p in McodesPrep.Icd10cmNeoplasms,
      order_by: [asc: p.title],
      where: fragment("(?) @@ plainto_tsquery(?)", p.title,   ^("#{main_term_field}%")  ),
      select: %{main_term: fragment("? ", p.main_term),
                title: fragment(" ? ",  p.title)
      },
      limit: 10

    records_b =  main_term_q |> McodesPrep.Repo.all

    if Enum.any?(records_b) do
      IO.puts " "
      print_results_title(main_term_field)
      IO.puts " "
      Enum.map(records_b, fn(rec) ->

        main_term_rec = rec[:main_term]
        main_term = main_term_rec |>  Iteraptor.from_flatmap
        title = rec[:title]

        format_title(title)
        show_tabular(main_term)
        IO.puts " "

      end )

    else
      colorize_text("alert", "Nothing Found")
    end
    response = get_response( "Search Again in  Neoplasms? [Y,N]") |> String.upcase

    case response do
      "Y" ->
        search_cm_neoplasms()
      "N" ->
        colorize_text("default", "Ok. help for options, q to Quit")
      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end


  end
  ##############################
  defp format_title(title) do
    IO.puts IO.ANSI.blue_background() <> IO.ANSI.white() <> " ❄❄❄ Term Title: #{title} ❄❄❄ " <> IO.ANSI.reset
  end

  ##########
  defp show_tabular(term) do
    {:ok, term_row_agent} = Agent.start_link fn -> [] end
    # term_row = []

    Enum.each(term, fn(a) ->
      term_level = a[:term_level]
      intend = Utils.level_intend(term_level)
      term_see_probe =   a[:term_see]
      term_see_also_probe = a[:term_see_also]

     term_see =  if "#{term_see_probe}" != "" do
        "-See:"  <> "#{term_see_probe}"
      else
        " "
      end

     term_see_also =     if "#{term_see_also_probe}" != "" do
        "-See Also:"  <> "#{term_see_also_probe}"
      else
        " "
      end
      term_cell_l = a[:term_cell_l]
      term_title = intend <> a[:term_title]
      <> a[:term_nemod]
      <> " "
      <> "#{term_see}"
      <> " "
      <> "#{term_see_also}"

     a_row =  if term_cell_l != nil  do

        cell_row = Enum.reduce(term_cell_l, [], fn(x, acc) ->
          [ x[:cell_code] | acc ]
        end)

        cell_row_ordered = cell_row |> Enum.reverse
            [term_title | cell_row_ordered]
      else
           [term_title | []]
      end#if

      Agent.update(term_row_agent, fn term_row -> [a_row | term_row] end)

    end)##Enum.each(term..)

    table_rex_rows =    Agent.get(term_row_agent, fn term_row -> term_row end)
    rex_rows = table_rex_rows |> Enum.reverse()
    title = "-------Results For Neoplasms------"
    header = ["Neoplasm",  "Mal. Primary", "Mal. Secondary", "Ca in situ",
              "Benign", "Uncertain Beh.",  "Unspecified Beh." ]

    TableRex.quick_render!(rex_rows, header, title)
    |> IO.puts

    Agent.stop(term_row_agent)


  end#function show_tabular

  ########################
end# module
