defmodule McodesPrep.MakeIcd10pcsIndex do
  import  SweetXml
  require Ecto.Query
  require Logger
  import  McodesPrep.Utils
  alias   McodesPrep.Utils, as: Utils


  def set_pcs_index_xml_file do
    IO.gets("\t Location of ICD10-PCS INDEX XML file i.e: data/icd10pcs_index_2021.xml  > ")  |> String.trim
  end
  ########################
  def pcs_index_xml_file do
    pcs_index_file= set_pcs_index_xml_file()
    file_existance(pcs_index_file)
  end

  ########################
  ################
  def pcs_index_xml_list do
    pcs_index_xml_file() |> xpath(
      ~x"//letter"l,
      letter_title: ~x"./title/text()"s,
      main_term_l: [
        ~x".//mainTerm"l,
        main_title: ~x"./title/text()"s,
        main_use: ~x"./use/text()"so,
        main_see:  ~x"./see/text()"so,
        main_see_tab:  ~x"./see/tab/text()"so,
        main_see_codes:  ~x"./see/codes/text()"so,
        main_codes:  ~x"./codes/text()"so,
        main_code:  ~x"./code/text()"so,
        terms_l: [
          ~x".//term[@level=\"1\"]/descendant-or-self::*[@level]"l,
          term_level: ~x"./@level"so,
          term_title: ~x"./title/text()"so,
          term_use: ~x"./use/text()"so,
          term_codes: ~x"./codes/text()"so,
          term_code: ~x"./code/text()"so,
          term_see:  ~x"./see/text()"so,
          term_see_tab:  ~x"./see/tab/text()"so,
          term_see_codes:  ~x"./see/codes/text()"so
        ]


      ],
    )
  end #diag_xml_list
  ################

  #########################

  def make_pcs_index do
    colorize_text("default", "Im nearly Ready to Make icd10pcs_index table")

    response = ask_user()
    case response do
      "Y" ->
        pcs_index_as_list = pcs_index_xml_list()
        Enum.each(pcs_index_as_list, fn a_map ->  insert_icd10pcs_index(a_map) end)
        colorize_text("default", "Ok Thx ")
      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")
      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end


  end#make_pcs_index
  #######################
  def insert_icd10pcs_index(map) do
    main_term_l = map[:main_term_l]
    Enum.map(main_term_l, fn(l) ->
      title = l[:main_title]
      # {:ok, inserted} =
      McodesPrep.Repo.insert(%McodesPrep.Icd10pcsIndex{title: title, main_term: l})
    end )

  end
  #####################

  def search_pcs_index do
    print_searching_in("Search ICD-10-PCS Index File")
    main_term_field = get_response("Type a main term as: Change" )
    #organ_field = IO.gets( "\t " <> IO.ANSI.blue() <> "Optional: Type an organ term as: Bone >  " <> IO.ANSI.default_color())
    # |> String.trim

    main_term_q =
      Ecto.Query.from p in McodesPrep.Icd10pcsIndex,
      order_by: [asc: p.title],
      where: fragment("(?) @@ plainto_tsquery(?)", p.title,   ^("#{main_term_field}%")  ),
      # where: fragment("(?)  #>> '{main_title}' ilike (?)", p.main_term,   ^("#{main_term_field}%")  ),
      select: [ p.main_term],
      limit: 10

    #fragment("?->'angel_list'->>'name' LIKE '%' || ? || '%'", u.info, ^search_string))
    #fragment("?->'angel_list'->>'name' LIKE ?", u.info, ^("%" <> search_string <> "%)  )
    #fragment("?->>? ILIKE ?", p.map, "key_name", ^some_value)

    records_b =  main_term_q |> McodesPrep.Repo.all

    #if "#{organ_field}" !== ""  do
    #  view_terms_part(organ_field, records_b)
    #end #if

    if Enum.any?(records_b) do
      IO.puts " "
      print_results_title(main_term_field)
      IO.puts " "
      format_record(records_b)
      IO.puts ""
    else
      colorize_text("\t alert", "Nothing Found")
    end

    response = get_response( "Search Again in ICD-10-PCS Index File? [Y,N]") |> String.upcase
    case response do
      "Y" ->
        search_pcs_index()
      "N" ->
        colorize_text("default", "Ok. help for options, q to Quit")
      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end


  end
  ###############
  def format_record(records) do

    Enum.map(records, fn(l) ->
      terms_l = Enum.map(l, fn (x) -> x["terms_l"] end)

      main_title = Enum.map(l, fn (x) -> x["main_title"] end)
      main_code = Enum.map(l, fn (x) -> x["main_code"] end)
      main_codes = Enum.map(l, fn (x) -> x["main_codes"] end)
      main_see_probe = Enum.map(l, fn (x) -> x["main_see"] end)
      main_see_codes = Enum.map(l, fn (x) -> x["main_see_codes"] end)
      main_see_tab = Enum.map(l, fn (x) -> x["main_see_tab"] end)
      main_use_probe = Enum.map(l, fn (x) -> x["main_use"] end)

      main_use =  if "#{main_use_probe}" != "" do
        IO.ANSI.normal() <> IO.ANSI.italic() <> " use " <> IO.ANSI.not_italic() <> "#{main_use_probe}"
      else
        " "
      end

      main_see =  if "#{main_see_probe}" != "" do
        IO.ANSI.normal() <> IO.ANSI.italic() <> " see " <> IO.ANSI.not_italic() <> "#{main_see_probe}"
      else
        " "
      end

      IO.puts  " "

      colorize_text("main_term", " "
        # <> IO.ANSI.reverse()
        <> IO.ANSI.blue_background()
        <> IO.ANSI.white()
        <> " ❄❄❄ Term Title: #{main_title} ❄❄❄ "
        <> IO.ANSI.reset
        #<> "#{main_title}"
        #<> IO.ANSI.reverse_off()
        <> "  " <> "#{main_code}"
        <> "  " <> "#{main_see}"
        <> "  " <> "#{main_see_tab}"
        <> "  " <> "#{main_see_codes}"
        <> "  " <> "#{main_use}"
        <> "  " <> "#{main_codes}"
      )

      if  Enum.any?(terms_l) do
        Enum.map(terms_l, fn(terms) ->
          Enum.map(terms, fn(a_term) ->
            format_term(a_term)
          end)##a_term
        end)
      end #if
    end)

  end##format_record
  #############
  @doc """
  First get rid the empty data keys
  """
  def format_term(a_term) do
    a = a_term |> Enum.filter(fn {_, v} -> v != "" end)
    |> Enum.into(%{})

    term_level = a["term_level"]
    intend = Utils.level_intend(term_level)

    term_title = a["term_title"]
    term_codes = a["term_codes"]
    term_use_probe = a["term_use"]
    term_see_probe = a["term_see"]
    term_see_codes = a["term_see_codes"]
    term_see_tab  = a["term_see_tab"]
    term_code = a["term_code"]

    term_use = if "#{term_use_probe}" != "" do
      IO.ANSI.italic() <> " use " <> IO.ANSI.not_italic() <> "#{term_use_probe}"
    else
      " "
    end

    term_see =  if "#{term_see_probe}" != "" do
      IO.ANSI.italic() <> " see " <> IO.ANSI.not_italic() <> "#{term_see_probe}"
    else
      " "
    end

    colorize_text("default_write", intend
      <> "#{term_title}"
      <> " "  <> "#{term_use}"
      <> IO.ANSI.bright()
      #<> IO.ANSI.blue()
      <> "  "  <> "#{term_code}"
      <> "  "  <> "#{term_codes}"
      <> IO.ANSI.reset()
    )

    colorize_text("default",  " "  <>  "#{term_see}"
      <> "  " <> "#{term_see_codes}"
      <> "  " <> "#{term_see_tab}" )


  end##format_term
  #######################
  def view_terms_part(organ_field, records) do
    Enum.map(records, fn(l) ->
      terms_l = Enum.map(l, fn (x) -> x["terms_l"] end)

      if  Enum.any?(terms_l) do
        Enum.map(terms_l, fn(terms) ->
          title_l = Enum.map(terms, fn (x) -> x["term_title"] end)
          for title <- title_l do 
           if title  == "#{organ_field}" do
              colorize_text("alert","**************")
              inspect_data(terms)
          end #if
          end

        end)
      end #if

end) #Enum.map

  end #def
###########END MODULE#########
end##module
