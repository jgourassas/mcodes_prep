defmodule McodesPrep.MakeIcd10cm do
  @moduledoc """
  Module to tranform ICD-10-CM XML tabular File
  to Postgresql Table (icd10cm), and then to
  search in this db table

  """
  import  SweetXml
  import Ecto.Query

  alias   McodesPrep.Repo
  require Logger

  import  McodesPrep.Utils
  alias   McodesPrep.Utils

  # require TableRex.Table


  @doc """
  Ask where the tabular file is located and check ist existance

  """
  def xml_file do
    tabular_file_string =IO.gets("\t Location of Tabular File i.e. : data/icd10cm_tabular_2021.xml > ")  |> String.trim
    file_existance(tabular_file_string)
  end

  @doc """
  Old solution.
  Extracts from ICD10-CM the icd10cm_code_2,  Diagnosis etc, But not the chapters...
  """
  def diag_xml_list do
    xml_file() |> xpath(
      ~x"//diag"l,
      icd10cm_code_2: ~x"./name/text()"s,
      long_description: ~x"./desc/text()"s,
      includes: [
        ~x"./includes/note"l,
        note: ~x"./text()"s
      ],
      inclusionTerm: [
        ~x"./inclusionTerm/note"l,
        note: ~x"./text()"s
      ],
      excludes1: [
        ~x"./excludes1/note"l,
        note: ~x"./text()"s
      ],
      excludes2: [
        ~x"./excludes2/note"l,
        note: ~x"./text()"s
      ],
      codeFirst: [
        ~x"./codeFirst/note"l,
        note: ~x"./text()"s
      ],
      codeAlso: [
        ~x"./codeAlso/note"l,
        note: ~x"./text()"s
      ],
      useAdditionalCode: [
        ~x"./useAdditionalCode/note"l,
        note: ~x"./text()"s
      ]
    )
  end #diag_xml_list
  ################
  @doc """
  Old solution. Is inserts the orders file (csv) to DB
  """
  def make_cm_orders do

    colorize_text("default", "--- I will prepare  the ICD-10-CM order file to ^ delemited  ---" )
    response = ask_user()
    case response do
      "Y" ->
        #order_file_string = set_order_file()
        order_file_string = IO.gets("\t Location of order File i.e. : data/icd10cm_order_2017.txt > ")  |> String.trim

        f_order =   file_existance(order_file_string)
        output_file = "data/icd10cm_order_transformed.txt"

        f_order  |> Stream.map( fn(line) ->
          slice_line_orders(line)
        end)
        |> Stream.into( File.stream!(output_file) )
        |> Stream.run
        colorize_text("info",
          "
          Order Icd10cm File was prepared for storage in the icd10cm postgresql table\n
          The file is locate in data/icd10cm_order_transformed.txt\n
          Please now check/correct and  run the data/copy_to_icd10cm_codes.sql and then
          the data/shape_icd10cm.sql
          ")

      "N" ->
        colorize_text("default", "--- O.K No hard fillings  ---" )
      _ ->
        colorize_text("default", "--- Please Type Y or N  ---" )


    end



  end
  ####################
  @doc """
  Old function. Not in use
  """
  def make_cm_diagnosis do
    colorize_text("default", "Im nearly Ready to Store Diagnosis elements")

    response = ask_user()
    case response do
      "Y" ->
        colorize_text("default", "Question: ")

        icd10cm_as_list = diag_xml_list()
        Enum.each(icd10cm_as_list, fn a_map -> get_diag_from_tabular(a_map) end)
        colorize_text("default", "Ok Thx ")

      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")


      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end

  end #parse_tabular
  ##############################
  defp get_diag_from_tabular(map) do
    code = map[:icd10cm_code_2]

    includes_l = map[:includes]
    includes = make_notes(includes_l)

    inclusionTerm_l= map[:inclusionTerm]
    inclusionTerm = make_notes(inclusionTerm_l)

    excludes1_l= map[:excludes1]
    excludes1 = make_notes(excludes1_l)

    excludes2_l =  map[:excludes2]
    excludes2 =  make_notes(excludes2_l)

    codeFirst_l = map[:codeFirst]
    codeFirst = make_notes(codeFirst_l)

    codeAlso_l = map[:codeAlso]
    codeAlso  = make_notes(codeAlso_l )

    useAdditionalCode_l = map[:useAdditionalCode]
    useAdditionalCode  = make_notes(useAdditionalCode_l )

    #icd10cm2 = ParseIcd10.Icd10cm |>  Repo.get_by(icd10cm_code_2: code)
    #Repo.update!(update_icd10cm)
    icd10cm = McodesPrep.Icd10cm |> Repo.get_by(icd10cm_code_2: code)
    #changeset = McodesPrep.MakeIcd10cm.changeset(icd10cm,
    changeset = McodesPrep.Icd10cm.changeset(icd10cm,
      %{codealso: codeAlso,
        includes: includes,
        codefirst: codeFirst,
        excludes1: excludes1,
        excludes2: excludes2,
        inclusionterm: inclusionTerm,
        useadditionalcode: useAdditionalCode
      })
    Repo.update!(changeset)
    IO.puts "Updating icd10cm_code_2: #{icd10cm.icd10cm_code_2}"
  end
  #####################
  ##make_notes receives notes which is a list of maps
  ##concatenates all maps to one as  string

  defp make_notes(notes) do
    all_notes = Enum.map(notes, fn(a_map) -> " ^" <> a_map[:note]   end )
    List.to_string(all_notes)
  end
  ################
  ################
  def make_chapters do
    colorize_text("default", "--- Starting parsing and storing chapters  ---" )

    response = ask_user()
    case response do
      "Y" ->
        icd10cm_as_list = chapter_xml_list()
        ProgressBar.render_spinner([frames: :bars, text: "Chapter: "], fn ->
          # ProgressBar.render_spinner [text: "Inserting ICD10-CM - Chapters, Sections,  ...", done: "Done."], fn ->
          Enum.each(icd10cm_as_list, fn a_chapter ->
            chapter_id = a_chapter[:chapter_id]

            chapter_description = a_chapter[:chapter_description]
            sections_l = a_chapter[:sections]

            Enum.map(sections_l, fn(section) ->
              section_id = section[:section_id]

              section_description =  section[:section_description]
              section_codes_l = section[:ic10cm_code_2]

              Enum.map(section_codes_l, fn(a_code) ->
                store_upate_chapters(chapter_id,
                  chapter_description,
                  section_id,
                  section_description,
                  a_code )
              end )

            end )

          end)
          :timer.sleep 2000
        end) ##Progresbar


        ########
        "N" ->
        colorize_text("default"," --- Ok. Next Time  ---" )
      _ ->
        colorize_text("alert"," --- Please Type Y or N  ---" )
    end# ask

  end#function

  ################
  @doc """
  Extracts only the chapters_name, chapter_description, section_id
  section_description, and the constructed icd10cm_code_2.

  """
  def chapter_xml_list do
    xml_file() |> xpath(
      ~x"/ICD10CM.tabular/chapter"l,
      chapter_id: ~x"./name/text()"s,
      chapter_description: ~x"./desc/text()"s,
      sections: [
        ~x"./section"l,
        section_id: ~x"./@id"s,
        section_description: ~x"./desc/text()"s,
        ic10cm_code_2: ~x"./diag/name/text()"ls
      ]

    )
  end

  def search_codes(qcode) do
    from(d in McodesPrep.Icd10cm,
      where: fragment("(?) ilike(?)", d.icd10cm_code_2,   ^("#{qcode}%")  ) )
      |> Repo.all
  end
  ############

  ###################

  defp store_upate_chapters(
    chapter_name,
    chapter_description,
    section_id,
    section_description,
    icd10cm_code_2) do
    ############################
    #IO.puts "------ --------------------------------------------"
    IO.write "#{chapter_name}"
    icd10cm =  search_codes(icd10cm_code_2)
    Enum.map(icd10cm, fn(icd10cm_record) ->

      changeset = McodesPrep.Icd10cm.changeset(icd10cm_record,
      %{chapter_name: chapter_name,
        chapter_description: chapter_description,
        section_id: section_id,
        section_description:  section_description
      } )
      Repo.update!(changeset)
    end )
    #########################
  end
  ################
  def all_xml_tabular do
    xml_file() |> xpath(
      ~x"/ICD10CM.tabular/chapter"l,
      chapter_name: ~x"./name/text()"s,
      #chapter_id: ~x"./name/text()"s,
      chapter_description: ~x"./desc/text()"s,
      sections_l: [
        ~x"./section"l,
        section_id: ~x"./@id"s,
        section_description: ~x"./desc/text()"s,
        diagnosis_l: [
          ~x"//diag"l,
          icd10cm_code_2: ~x"./name/text()"s,
          long_description: ~x"./desc/text()"s,
          includes: [
            ~x"./includes/note"l,
            note: ~x"./text()"s
          ],
          inclusionTerm: [
            ~x"./inclusionTerm/note"l,
            note: ~x"./text()"s
          ],
          excludes1: [
            ~x"./excludes1/note"l,
            note: ~x"./text()"s
          ],
          excludes2: [
            ~x"./excludes2/note"l,
            note: ~x"./text()"s
          ],
          codeFirst: [
            ~x"./codeFirst/note"l,
            note: ~x"./text()"s
          ],
          codeAlso: [
            ~x"./codeAlso/note"l,
            note: ~x"./text()"s
          ],
          useAdditionalCode: [
            ~x"./useAdditionalCode/note"l,
            note: ~x"./text()"s
          ]    ] ]  )
  end

  ############
  @doc """
  We use this fn for tranform the XML file to db table
  The other functions are not in use
  Asks the user for the tablular icd10cm file
  """
  def make_alternative() do
    colorize_text("default", "ICD-10-CM Tabular XML File TO Postgresql")

    response = ask_user()
    case response do
      "Y" ->

        cm_list = all_xml_tabular()
        Enum.each(cm_list, fn a_map ->  insert_alternative(a_map) end)
        colorize_text("default", "Ok Thx ")

        colorize_text("default", "Please  from inside psql mcodes_prep_repo run  the commands/shape_icd10cm.sql")
        colorize_text("default", "
        update icd10cm set is_category = 'Y' where length( icd10cm_code_2 ) < 4;
        update icd10cm set is_subcategory = 'Y' where length( icd10cm_code_2 ) <  6 AND length(icd10cm_code_2) > 4;
        ")
        colorize_text("default", "And As option the commands/shape_icd10cm_extra.sql")
      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")
      _ ->
        colorize_text("default", " --- Ok. Type h for Help, q to Quit--- ")
        McodesPrep.Cli.loop()

    end



  end
  ###################
  defp insert_alternative(map) do
    chapter_name = String.to_integer(map[:chapter_name])
    chapter_description = map[:chapter_description]


    sections_l = map[:sections_l]

    for a_s <- sections_l do
      section_id = a_s[:section_id]
      section_description= a_s[:section_description]
      diagnosis_l = a_s[:diagnosis_l]

      for diag <- diagnosis_l do
        icd10cm_code_2 = diag[:icd10cm_code_2]
        long_description = diag[:long_description]

        includes_l = diag[:includes]
        includes = make_notes(includes_l)

        inclusionterm_l= diag[:inclusionTerm]
        inclusionTerm = make_notes(inclusionterm_l)

        excludes1_l= diag[:excludes1]
        excludes1 = make_notes(excludes1_l)

        excludes2_l =  diag[:excludes2]
        excludes2 =  make_notes(excludes2_l)

        codeFirst_l = diag[:codeFirst]
        codeFirst = make_notes(codeFirst_l)

        codeAlso_l = diag[:codeAlso]
        codeAlso  = make_notes(codeAlso_l )

        useAdditionalCode_l = diag[:useAdditionalCode]
        useAdditionalCode  = make_notes(useAdditionalCode_l )

        inspect_data(icd10cm_code_2)

        # {:ok, inserted} =
        McodesPrep.Repo.insert(%McodesPrep.Icd10cm{
              chapter_name: chapter_name,
              chapter_description: chapter_description,
              section_id: section_id,
              section_description: section_description,
              icd10cm_code_2:  icd10cm_code_2,
              long_description:   long_description,
              includes: includes,
              inclusionterm: inclusionTerm,
              excludes1:   excludes1,
              excludes2: excludes2,
              codefirst: codeFirst,
              codealso: codeAlso,
              useadditionalcode: useAdditionalCode,
})

      end# for diag


    end #for section

    ###################
  end# insert

  ##################
  def make_cm_json do
    colorize_text("default", "--- I am Ready to make JSON Files From ICD-10-CM ---" )

    response = ask_user()
    case response do
      "Y" ->
        colorize_text("default", "I will ask few times for the Location of ICD10-CM File")

        diag_list = diag_xml_list()
        #chapters_list = chapter_xml_list()
        #all_list = all_xml_tabular()

        File.write("data/diagnosis.json", Poison.encode!(diag_list, pretty: true), [:binary])
        colorize_text("default", "* --JSON File created. Can be found as:  data/diagnosis.json")

        chapters_list = chapter_xml_list()
        File.write("data/chapters.json", Poison.encode!(chapters_list, pretty: true), [:binary])
        colorize_text("default", "* --JSON File created. Can be found as:  data/chapters.json")

        all_list = all_xml_tabular()
        File.write("data/all_tabular.json", Poison.encode!(all_list, pretty: true), [:binary])
        colorize_text("default",  "* --JSON File ceated. Can be found as:  data/all_tabular.json")
      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")
      _ ->
        colorize_text("alert", "---Please Type Y or N ---")
    end
  end
  ########################
  def search_icd10cm do
    print_searching_in("Search In ICD-10-CM Tabular Files")
    term = get_response("Type as:  Malaria Ovale / B53.0" )

    #query1 =  Ecto.Query.from p in McodesPrep.Icd10cm,
    #  order_by: [asc: p.icd10cm_code_2],
    #  where: fragment("(?) @@ plainto_tsquery(?)", p.long_description,   ^("#{term}%")  )
    #or fragment("(?) ilike(?)", p.icd10cm_code_2,   ^("#{term}%") ),
    #  select: [ p.icd10cm_code_2, p.long_description],
    #  limit: 12

    query =  Ecto.Query.from p in McodesPrep.Icd10cm,
      order_by: [asc: p.icd10cm_code_2],
      where: fragment("(?) @@ plainto_tsquery(?)", p.long_description,   ^("#{term}%")  )
    or fragment("(?) ilike(?)", p.icd10cm_code_2,   ^("#{term}%") ),
      # select: [ p.icd10cm_code_2, p.long_description],
      select: %{
        codealso: p.codealso,
        codefirst: p.codefirst,
        excludes1: p.excludes1,
        excludes2: p.excludes2,
        code: p.icd10cm_code_2,
        includes: p.includes,
        inclusionterm: p.inclusionterm,
        desc: p.long_description,
        useadditionalcode: p.useadditionalcode
      },
      limit: 12

    records =  query |> McodesPrep.Repo.all
    header = ["ICD-10-CM CODE", "DESCRIPTION"]
    title = "Results For #{term}. Limited to 12 Records"

    if Enum.any?(records) do
      table_data_l = Enum.reduce(records, [], fn(x, acc) ->
      
      if x !== nil do
        {:ok, cm_graphics_agent} = Agent.start_link fn ->  "" end

          make_symbols(x, cm_graphics_agent)

          symbols =  Agent.get(cm_graphics_agent, fn graphics -> graphics end)

          Agent.stop(cm_graphics_agent)

           [ [ x[:code], x[:desc] <> " " <>  symbols <> " " ] | acc ]
        end #if
      end)

      table_data = Enum.reverse(table_data_l)
      print_results_title(term)
      Utils.present_tablerex(table_data, header, title)
   

    else
      colorize_text("alert", "Nothing Found")
    end
    response_options()

  end
  ###################
  defp make_symbols(x_data, cm_graphics_agent) do

   for x <- x_data do
     {key, value} = x
       
      if value !== ""  do
        pick_symbol(key, cm_graphics_agent)
      end# if
     end# for

  end # make_symbols

  ###################
  def pick_symbol(key, cm_graphics_agent) do
cond do
          key == :codealso ->

            code_also = " " <> "ca" 
            Agent.update(cm_graphics_agent, fn graphics -> code_also <> graphics end)

           key == :codefirst ->
            code_first =  " " <> "cf" 
            Agent.update(cm_graphics_agent, fn graphics -> code_first <>  graphics end)

          key == :excludes1  ->
         ex1 = " " <> "ex1"
         Agent.update(cm_graphics_agent, fn graphics -> ex1 <>  graphics end)

          key == :excludes2 ->
            ex2 =  " " <> "ex2" 
           Agent.update(cm_graphics_agent, fn graphics -> ex2 <> graphics  end)

          key == :includes ->
            includes =  " " <> "inc" 
            Agent.update(cm_graphics_agent, fn graphics -> includes <>  graphics  end)

          key == :inclusionterm ->
          inclusion_term = " " <> "incT"
          Agent.update(cm_graphics_agent, fn graphics -> inclusion_term <>  graphics  end)

          key == :useadditionalcode ->
            useadditionalcode =  " " <>   "uaC" 
            Agent.update(cm_graphics_agent, fn graphics ->   useadditionalcode <> graphics end)

          true ->
            ""
        end#cond


  end
####################
  def show_record() do
    print_searching_in("Search In ICD-10-CM Tabular Files For a single Code")

    code = get_response("Type a Code as:  I25.72, I25.711")

    query =  Ecto.Query.from p in McodesPrep.Icd10cm,
      order_by: [asc: p.icd10cm_code_2],
      where: p.icd10cm_code_2 ==  ^"#{code}",
      select: %{
        chapter_desc: p.chapter_description,
        chapter_name:  p.chapter_name,
        codealso: p.codealso,
        codefirst: p.codefirst,
        excludes1: p.excludes1,
        excludes2: p.excludes2,
        code: p.icd10cm_code_2,
        includes: p.includes,
        is_category: p.is_category,
        is_header: p.is_header,
        is_subcategory: p.is_subcategory,
        inclusionterm: p.inclusionterm,
        desc: p.long_description,
        section_id: p.section_id,
        section_description: p.section_description,
        useadditionalcode: p.useadditionalcode

      },
      limit: 10

    record =  query |> McodesPrep.Repo.all
    #############
    for rec <- record do
      chapter_desc = rec[:chapter_desc]
      chapter_name = rec[:chapter_name]
      codealso = rec[:codealso]
      codefirst = rec[:codefirst]
      excludes1= rec[:excludes1]
      excludes2= rec[:excludes2]
      code = rec[:code]
      includes = rec[:includes]
      is_category = rec[:is_caterory]
      is_header = rec[:is_header]
      is_subcategory= rec[:is_subcategory]
      inclusionterm = rec[:inclusionterm]
      desc = rec[:desc]
      section_id = rec[:section_id]
      section_description =  rec[:section_description]
      useadditionalcode =  rec[:useadditionalcode]

      IO.puts ""
      print_results_title(code)


      print_element(desc, "Description")
      print_element(codealso, "Code Also")
      print_element(codefirst, "Code First")
      print_element(excludes1, "Excludes1")
      print_element(excludes2, "Excludes2")
      print_element(includes, "Includes")
      print_element(inclusionterm, "Inclusion Term")
      print_element(useadditionalcode, "Use Additional Code")

      colorize_text("warn", "❤" <> " Chapter - Section "<> "❤")

      if chapter_name !== "" do
        colorize_text("default", IO.ANSI.italic() <>"Chapter Name:  " <> IO.ANSI.not_italic() <> "#{chapter_name}")
      end


      if chapter_desc !== "" do
        colorize_text("default", IO.ANSI.italic() <>"Chapter Description: " <> IO.ANSI.not_italic() <> "#{chapter_desc}")
      end


      if section_id !== "" do
        colorize_text("default", IO.ANSI.italic() <>"Section: " <> IO.ANSI.not_italic() <> "#{section_id}")
      end

      if section_description !== "" do
        colorize_text("default", IO.ANSI.italic() <>"Section Description: " <> IO.ANSI.not_italic() <> "#{section_description}")
      end
      if is_category !== nil do
        colorize_text("default", IO.ANSI.italic() <>"Is Category:  " <> IO.ANSI.not_italic() <> "#{is_category}")
      end
      if is_subcategory !== nil do
        colorize_text("default", IO.ANSI.italic() <>"Is  Sub Category:  " <> IO.ANSI.not_italic() <> "#{is_subcategory}")
      end

      if is_header !== nil do
        colorize_text("default", IO.ANSI.italic() <>"Is Header:  " <> IO.ANSI.not_italic() <> "#{is_header}")
      end

      IO.puts " "
    end#for

    #############

    response_options()



  end##show_record
  #################
  def response_options() do
    response = get_response(" Search in ICD-10-CM Again? [Y,N] / Show Single Record [R] / View Abbr[A]  ")


    case response do
      "Y" ->
        search_icd10cm()

      "R" ->
        show_record()
      "A" ->
        view_abbraviations()
        search_icd10cm()

      "N" ->
        colorize_text("default", "Ok. help for options")
        McodesPrep.Cli.loop()
      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end#case

  end# response_options

  #####################
  def view_abbraviations() do
    colorize_text("warn", "Abbreviations: ")
    colorize_text("default_write", "ca = Code Also, cf = Code First, ex1 = excludes1, ex2 = excludes2, inc = Includes, incT = inclusion Term, uaC = Use Additional Code")
    IO.puts ""
  end

  ########################
end#module
