defmodule McodesPrep.MakeIcd10cmDindex do
@moduledoc """
   To Transform the Drug Index of ICD-10-CM
"""
  import  SweetXml
  require Ecto.Query

  alias McodesPrep.MakeIcd10cm
  alias TableRex.Table
  require Logger
  import  McodesPrep.Utils
  alias   McodesPrep.Utils, as: Utils


  def set_dindex_xml_file do
    IO.gets("\t Location of ICD10-CM DRUG INDEX XML file i.e: data/icd10cm_drug_2022.xml  > ")  |> String.trim
  end
  ########################
  def dindex_xml_file  do
    dindex_file = set_dindex_xml_file()
    file_existance(dindex_file)
  end
#################

def dindex_xml_list do
   dindex_xml_file() |> xpath(
        ~x[//letter]l,
      letter_title: ~x"./title/text()"s,
      main_terms_l: [
            ~x".//mainTerm"l,
            main_title: ~x"./title/text()"s,
            main_nemod:  ~x"./title/nemod/text()"s,
            main_see: ~x"./see/text()"s,
            main_see_also: ~x"./seeAlso/text()"s,
            main_cell_l: [
                   ~x"./cell"lo,
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

defp insert_dindex(map) do
main_terms_l = map[:main_terms_l]

    Enum.each(main_terms_l, fn(main_term) ->

       main_title = main_term[:main_title]
       colorize_text("default", "Inserting Main Title: " <> "#{main_title}")

       terms_map =   main_term |> Iteraptor.to_flatmap

       # {:ok, inserted} =
       McodesPrep.Repo.insert(%McodesPrep.Icd10cmDindex{title: main_title,
          main_term: terms_map})

end)##Enum.each

end### fn inseert_dindex

  ########################
def make_dindex do
    colorize_text("default", "Insert icd10cm Drug Index to PG tables?")

    response = ask_user()
    case response do
      "Y" ->
        colorize_text("default", "Question: ")

        dindex_as_list = dindex_xml_list()
        Enum.each(dindex_as_list, fn a_map ->  insert_dindex(a_map) end)
        colorize_text("default", "Ok Thx ")

      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")


      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end


  end#make_pcs_index
  #######################
def search_dindex()  do
  print_searching_in("Search ICD-10-CM DRUG File" )
    main_term_field = get_response("Type a Title as: Aspirin, Belladonna,  Food " )

    main_term_q =
      Ecto.Query.from p in McodesPrep.Icd10cmDindex,
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
    response = get_response("Search again [Y,N] / Search In Tabular[S] ")

    case response do
      "Y" ->
        search_dindex()

      "S" ->
        MakeIcd10cm.search_icd10cm()
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
###############
defp show_tabular(term) do
 {:ok, dindex_agent} = Agent.start_link fn -> [] end
  # dindex_row = []

      # term_level = term[:term_level]
      main_see_probe =   term[:main_see]
      main_see_also_probe = term[:main_see_also]

      main_see =   if "#{main_see_probe}" != "" do
        #If you change the color breaks the vertical alignment of table
        # IO.ANSI.light_blue() <> "-See "  <> "#{main_see_probe}" <> IO.ANSI.normal()
        "-See "  <> "#{main_see_probe}"
      else
         " "
      end

      main_see_also =   if "#{main_see_also_probe}" != "" do
        #IO.ANSI.light_blue() <> "-See Also "  <> "#{main_see_also_probe}" <> IO.ANSI.normal()
        "-See Also "  <> "#{main_see_also_probe}"
      else
        " "
      end


      main_title = term[:main_title]
                   <> term[:main_nemod]
                   <> " "
                   <> "#{main_see}"
                   <> " "
                   <> "#{main_see_also}"


  ########################
  main_cell_l = term[:main_cell_l]

   if main_cell_l != nil do

    main_cell_row = Enum.reduce(main_cell_l, [], fn(x, acc) ->
           [ x[:main_cell_code] | acc ]
       end)

    main_cell_row_ordered = main_cell_row |> Enum.reverse

    main_row = [main_title | main_cell_row_ordered]

     Agent.update(dindex_agent, fn dindex_row -> [main_row | dindex_row] end)

    else
      main_row = [main_title | []]
     Agent.update(dindex_agent, fn dindex_row -> [main_row | dindex_row] end)

   end#if main


  terms_l = term[:terms_l]

  if terms_l != nil do

  Enum.each(terms_l, fn(term) ->
     term_a = term[:term]

    for a  <- term_a do
    term_level = a[:term_level]
    intend = Utils.level_intend(term_level)
    term_see_probe =   a[:term_see]
    term_see_also_probe = a[:term_see_also]

    term_cell_l  = a[:term_cell_l]
    ############
     term_see = if "#{term_see_probe}" != "" do
          "See:"  <> "#{term_see_probe}"
      else
         " "
      end

     term_see_also =  if "#{term_see_also_probe}" != "" do
         "See Also:"  <> "#{term_see_also_probe}"
      else
         " "
      end

     term_title = intend <> a[:term_title]
                   <> a[:term_nemod]
                   <> " "
                   <> "#{term_see}"
                   <> " "
                   <> "#{term_see_also}"



    ##############
    term_cell_row = Enum.reduce(term_cell_l, [], fn(x, acc) ->
           [ x[:cell_code] | acc ]
       end)

    term_cell_row_ordered = term_cell_row |> Enum.reverse

    term_row = [term_title | term_cell_row_ordered]

    Agent.update(dindex_agent, fn dindex_row -> [term_row | dindex_row] end)

     end

  end) #Enum terms_l

  end# if terms_l




  table_rex_rows =    Agent.get(dindex_agent, fn dindex_row -> dindex_row end)
  rex_rows = table_rex_rows |> Enum.reverse()
  title = "-------Poisoning------"
  header = ["Substance",  "Accidental", "Intentional", "Assault" ,"Undetermined",
            "Adverse effect ", "Underdosing"]

     Table.new(rex_rows, header, title)
|> Table.put_header_meta(0..6, color: IO.ANSI.color(31))
|> Table.put_column_meta(0, align: :left, padding: 5) # `0` is the column index.
|> Table.put_column_meta(0, color: :blue) # sets column header to red, too
|> Table.put_column_meta(1..5, align: :left) # `1..2` is a range of column indexes. :all also works.
|> Table.render!
|> IO.puts


   #TableRex.quick_render!(rex_rows, header, title)
   #|> IO.puts

  Agent.stop(dindex_agent)


end

###################
end# module
