defmodule McodesPrep.MakeIcd10pcs do
  import  SweetXml
  import  Ecto.Query
  alias   McodesPrep.Repo
  require Logger
  import  McodesPrep.Utils
  alias   McodesPrep.Utils, as: Utils
  import  ProgressBar 

  ##########################
  _format = [
    bar_color: [IO.ANSI.green_background],
    blank_color: [IO.ANSI.red_background],
    bar: " ",
    blank: " ",
    left: " ", right: " ",
  ]
  #####################
  def make_pcs_orders do
    colorize_text("default", "--- I will prepare  the ICD-10-PCS order file to ^ delemited\n
      ICD-10-PCS order files contain a unique order number  \n
      a flag distinguishing valid codes from headers, and both long and short descriptions \n" )
    response = ask_user()
    case response do
      "Y" ->
        pcs_order_string = IO.gets("\t Location of ICD10-PCS order file i.e:  data/icd10pcs_order_2021.txt > ")  |> String.trim
        f_order = file_existance(pcs_order_string)
        output_file = "data/icd10pcs_order_transformed.txt"
        f_order |> Stream.map(fn(line) ->
          #The order files for ICD10CM and IC10PCS
          # have the same structure
          #slice_line_orders(line)
           Utils.slice_line_orders(line)

        end)
        |> Stream.into( File.stream!(output_file) )
        |> Stream.run
        colorize_text("info",
          "
          Now the Order Icd10PCS File was prepared for storage in the icd10pcs postgresql table\n
          The file is locate in data/icd10pcs_order_transformed.txt\n
          -----------------------------------------------------------------\n
          From command mode in the terminal do: psql mcodes_prep_repo
          \copy icd10pcs(order_number, icd10pcs_code, is_header, short_description, long_description)
          FROM 'data/icd10pcs_order_transformed.txt' with delimiter '^';\n
          -------------------------------------------------------------------\n
          If you finished with this  we are going to proceed to the next level building the\n
          codes for axis fields that means the section, body_system, body_part, approach and device\n
          ")
      "N" ->
        colorize_text("default", "--- O.K No hard fillings  ---" )

      _ ->

        colorize_text("default", "--- Please Type Y or N  ---" )
    end ## response


  end

  ############################

  def pcs_xml_file do
    pcs_file_string = set_pcs_xml_file()
    file_existance(pcs_file_string)
  end

  def set_pcs_xml_file do
    # IO.gets("data/icd10pcs_tables_2017.xml") |> String.trim
    IO.gets("\t Location of ICD10-PCS XML file i.e: data/icd10pcs_tables_2021.xml > ")  |> String.trim
  end
  #####################
  @doc """

  We start from pcsTable. Each pcsTable has One section + section_title,
  One body_system + body_system_title, One root_operation + root_operation_title
  But many pcsRow. Each pcsRow contains a list of body_parts, approaches, devices and qualifiers
  Example
  <pcsTable>
  <axis pos="1" values="1"> --> Is the section field
  <title>Section</title>   --> icd10pcs.section_title = Medical and Surgica
  <label code="0">Medical and Surgical</label> icd10pcs.section = 0
  </axis>
  <axis pos="2" values="1"> -> is the body_system_field
  <title>Body System</title> --> icd10pcs.body_system_title = Central Nervous Syste
  <label code="0">Central Nervous System</label> ----> icd10pcs.body_system = 0
  </axis>

  """
  def pcs_xml_list do

    pcs_xml_file() |> xpath(
      ~x"//pcsTable"l,
      section_l: [
        ~x".//axis[@pos=\"1\"]/label"l,
        section: ~x"./@code"s,
        section_title: ~x"./text()"s
      ],
      body_system_l: [
        ~x".//axis[@pos=\"2\"]/label"l,
        body_system: ~x"./@code"s,
        body_system_title: ~x"./text()"s
      ],
      root_operation_l: [
        ~x".//axis[@pos=\"3\"]/label"l,
        root_operation: ~x"./@code"s,
        root_operation_title: ~x"./text()"s
      ],
      pcsRow_l: [
        ~x".//pcsRow"l,
        body_part_l: [
          ~x".//axis[@pos=\"4\"]/label"l,
          body_part: ~x"./@code"s,
          body_part_title: ~x"./text()"s
        ],
        approach_l: [
          ~x".//axis[@pos=\"5\"]/label"l,
          approach: ~x"./@code"s,
          approach_title: ~x"./text()"s
        ],
        device_l: [
          ~x".//axis[@pos=\"6\"]/label"l,
          device: ~x"./@code"s,
          device_title: ~x"./text()"s
        ],
        qualifier_l: [
          ~x".//axis[@pos=\"7\"]/label"l,
          qualifier: ~x"./@code"s,
          qualifier_title: ~x"./text()"s
        ] ]
    )
  end
  ###############

  def find_pcsrow_codes(pcsrow_l, icd10pcs_code_1) do

    Enum.map(pcsrow_l, fn(a_row) ->

      ###body_part
      a_body_part_l =  a_row[:body_part_l]

      Enum.map(a_body_part_l, fn(a_part) ->

        a_body_part_code =  a_part[:body_part]
        body_part_code = icd10pcs_code_1 <> a_body_part_code

        bp_axis_field = "body_part"
        bp_axis_value = a_body_part_code
        bp_axis_title_field = "body_part_title"
        bp_axis_title_value = a_part[:body_part_title] |> String.trim()
        bp_code = body_part_code
        #IO.inspect "Body Part Value " <> bp_axis_value <> " Title: " <> bp_axis_title_value

        update_axis_field_titles(bp_axis_field, bp_axis_value, bp_axis_title_field, bp_axis_title_value, bp_code )

        ##### approach   ####
        an_approach_l =  a_row[:approach_l]

        Enum.map(an_approach_l, fn(an_approach) ->
          an_approach_code =  an_approach[:approach]
          approach_code =  body_part_code <> an_approach_code

          ap_axis_field = "approach"
          ap_axis_value = an_approach_code
          ap_axis_title_field = "approach_title"
          ap_axis_title_value = an_approach[:approach_title] |> String.trim()
          ap_code = approach_code

          update_axis_field_titles(ap_axis_field, ap_axis_value, ap_axis_title_field, ap_axis_title_value, ap_code )

          ###########device#######
          device_l =  a_row[:device_l]

          Enum.map(device_l, fn(device) ->
            a_device_code =  device[:device] |> String.trim()
            device_code =  approach_code <> a_device_code

            d_axis_field = "device"
            d_axis_value = a_device_code
            d_axis_title_field = "device_title"
            d_axis_title_value = device[:device_title] |> String.trim()
            d_code = device_code
            
            #IO.inspect(d_axis_field)
            #IO.inspect(d_axis_value)
            #IO.inspect(d_axis_title_field)
            #IO.inspect(d_axis_title_value)
            #IO.inspect(String.length(d_axis_title_value))
            colorize_text("default", "Building titles for Codes: \t" <> d_code )

            update_axis_field_titles(d_axis_field, d_axis_value, d_axis_title_field, d_axis_title_value, d_code )


            ######qualifier##############
            qualifier_l =  a_row[:qualifier_l]

            Enum.map(qualifier_l, fn(qualifier) ->
              a_qualifier_code =  qualifier[:qualifier]
              qualifier_code =  device_code <> a_qualifier_code

              q_axis_field = "qualifier"
              q_axis_value = a_qualifier_code
              q_axis_title_field = "qualifier_title"
              q_axis_title_value = qualifier[:qualifier_title]|> String.trim()
              q_code = qualifier_code

              update_axis_field_titles(q_axis_field, q_axis_value, q_axis_title_field, q_axis_title_value, q_code )


            end) ## qualifier
            #################
          end )##device
        end )##approach
      end)##body_part
      ###
    end)##
  end## find_pcsrow_codes


  #################
  ################
  def get_pcs_from_tabular(list) do

    section_l= list[:section_l] 
    body_system_l = list[:body_system_l]
    root_operation_l = list[:root_operation_l]
    code_l = section_l ++ body_system_l ++ root_operation_l

    [ a_section |  [ a_body_system  | [a_root_op | _]] ] = code_l

    icd10pcs_code_1 = a_section[:section] <> a_body_system[:body_system] <> a_root_op[:root_operation]
    a_section_title = a_section[:section_title]
    a_body_system_title = a_body_system[:body_system_title]
    a_root_op_title = a_root_op[:root_operation_title]

    #colorize_text("default", "Updating titles for Code: \t" <> icd10pcs_code_1 )
    ##Progressbar
  
  #Enum.each 1..100, fn (i) ->
  #ProgressBar.render(i, 100)
  #:timer.sleep 25
  #end
    update_axis_field_titles("section", a_section[:section], "section_title", a_section_title, icd10pcs_code_1)
    update_axis_field_titles("body_system", a_body_system[:body_system], "body_system_title", a_body_system_title, icd10pcs_code_1)
    update_axis_field_titles("root_operation", a_root_op[:root_operation], "root_operation_title", a_root_op_title, icd10pcs_code_1)

    pcsrow_l = list[:pcsRow_l]
    find_pcsrow_codes(pcsrow_l, icd10pcs_code_1)

  end
  #####################
  #######################
  @doc """
  Let say that we want to save in the axis fields theres's codes
  Axis fields are:
  section body_system root_operation body_part approach qualifier
  We collect from db the   icd10pcs_code  0SGC0JZ

  We slice up this field and then we have:

  section code is in position 0 and equals to 0
  .........
  qualifier code is in position 6 and equals to Z

  The we update the record with icd10pcs_code = 0SGC0JZ with these  results
  """
  def set_pcs_axis_field_codes do
    query =  Ecto.Query.from p in McodesPrep.Icd10pcs,
      order_by: [asc: p.icd10pcs_code]

    records = query |> McodesPrep.Repo.all
    Enum.map(records, fn(record) ->

      a_code = Map.get(record, :icd10pcs_code)

      section = String.at(a_code, 0)
      body_system = String.at(a_code, 1)
      root_operation = String.at(a_code, 2)
      body_part =  String.at(a_code, 3)
      approach = String.at(a_code, 4)
      device = String.at(a_code, 5)
      qualifier = String.at(a_code, 6)

      changeset = McodesPrep.Icd10pcs.changeset(record,
        %{section: section,
          body_system: body_system,
          root_operation: root_operation,
          body_part: body_part,
          approach: approach,
          device: device,
          qualifier:  qualifier
        } )
      Repo.update!(changeset)
      colorize_text("default", "Updating Code : " <> a_code)
    end)

  end
  @doc """
  Very slow function  for finding and inserting the title of icd10pcs
  """
  #################
  def update_axis_field_titles(axis_field, axis_value, axis_title_field, axis_title_value, code ) do

    axis_titles = Repo.all(from p in McodesPrep.Icd10pcs,
      where: ilike(p.icd10pcs_code, ^"#{code}%"  ),
      where: fragment( " ? = ?",  field(p, ^:"#{axis_field}"), ^axis_value) )


    Enum.map(axis_titles, fn(a_record) ->
      changeset = McodesPrep.Icd10pcs.changeset(a_record,
      %{"#{axis_title_field}": axis_title_value} )
      Repo.update!(changeset)
    end )
  end##update_axis_field_titles
  ######################
  @doc """
  Export icd10pcs database table to csv
  COPY icd10pcs TO '/tmp/icd10pcs.csv' DELIMITER ',' CSV HEADER;
  """
  def export_db_pcs_csv do
    colorize_text("default", "\t Form inside psql: \n
    COPY icd10pcs TO '/tmp/icd10pcs.csv' DELIMITER ',' CSV HEADER;")
  end
  #######################
  ########################
  def make_all_pcs_set_axis_fields() do

    colorize_text("default", "Seting  ICD-10-PCS axis Fields Values i.e section 0, body_system W, .. Estimated Time:  1198005.697  ms or  19 min")

    response_axis_fields = ask_user()
    case response_axis_fields  do
      "Y" ->

        set_pcs_axis_field_codes()
        colorize_text("default", "Finished Updating ICD-10-PCS axis Fields Values")

      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")
      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end

  end##make_all_pcs_set_axis_fields

  ################
  ##########################
  def make_all_pcs_set_axis_titles() do
    colorize_text("alert", "--- Updating  axis titles of ICD-10-PCS. \n
    as section_title, body_system_title, body_part_title etc\n
    Estimated Time: 12 unacceptable hours. Sorry!!!! \n
      Im stuck I can't find an other solution for the time being " )

    response = ask_user()
    case response do
      "Y" ->
        colorize_text("default", "Seting Field Titles. Please Be Patient")
        pcs_as_list = pcs_xml_list()
        pcs_as_list_reverse = Enum.reverse(pcs_as_list)
       # pcs_as_list = pcs_xml_list()


       #pcs_as_list_len = Enum.count(pcs_as_list)
        #IO.puts("---------Total list len -------------------------")
        #IO.inspect(pcs_as_list_len)


#Enum.each 1..pcs_as_list_len, fn (i) ->
#  ProgressBar.render(i, pcs_as_list_len)
#  :timer.sleep 30
#end

    Enum.each(pcs_as_list_reverse, fn(a_map) -> 
#        Enum.each(pcs_as_list, fn(a_map) -> 
         get_pcs_from_tabular(a_map) 
        
        end )

      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")
      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end

  end
  ########################

  ##################
  def search_pcs  do

    print_searching_in("Search ICD-10-PCS File")
    term = get_response("Type a term as:  Coronary radiography,  027334Z" )
    query =  Ecto.Query.from p in McodesPrep.Icd10pcs,
      order_by: [asc: p.long_description],
      where: fragment("(?) @@ plainto_tsquery(?)", p.long_description,   ^("#{term}%")  )
    or fragment("(?) ilike(?)", p.icd10pcs_code,   ^("#{term}%") )   ,
      select: [ p.icd10pcs_code, p.long_description, p.is_header],
      limit: 25


    records =  query |> McodesPrep.Repo.all
    header = ["CODE", "DESCRIPTION", "BILLABLE"]
    title = "Results For #{term}. Limited to 25 Records and ordered by DESCRIPTION"
    if Enum.any?(records) do
      print_results_title(term)
      Utils.present_tablerex(records, header, title)
    else
      colorize_text("alert", "Nothing Found")
    end #Enum.any

    response_options()
  end##view_pcs
  ###########################
  def response_options() do
    response = get_response( "Search in ICD-10-PCS Again? [Y,N] / Show Single Record [R]") |> String.upcase
    case response do
      "Y" ->
        search_pcs()

      "R" ->
        show_pcs_record()

      "N" ->
        colorize_text("default", "Ok. help for options")
        McodesPrep.Cli.loop()
      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end#case

  end# response_options
  #########################
  def show_pcs_record() do
    print_searching_in("Search In ICD-10-PCS Tabular Files For a Single Code")
    code = get_response("Type a single Code as:  5A1945Z, 5A1955Z, 5A1935Z, 0FB" )
    query =  Ecto.Query.from p in McodesPrep.Icd10pcs,
      order_by: [asc: p.icd10pcs_code],
      where: p.icd10pcs_code ==  ^"#{code}",
      select: %{
        icd10pcs_code: p.icd10pcs_code,
        is_header: p.is_header,
        long_description: p.long_description,
        section: p.section,
        section_title: p.section_title,
        body_system: p.body_system,
        body_system_title: p.body_system_title,
        root_operation: p.root_operation,
        root_operation_title: p.root_operation_title,
        body_part: p.body_part,
        body_part_title: p.body_part_title,
        approach: p.approach,
        approach_title: p.approach_title,
        device: p.device,
        device_title: p.device_title,
        qualifier:   p.qualifier,
        qualifier_title: p.qualifier_title

      },
      limit: 1

    record =  query |> McodesPrep.Repo.all
    print_results_title(code)

    if Enum.any?(record) do
      for rec <- record do
        icd10pcs_code = rec[:icd10pcs_code]

        is_header = rec[:is_header]

        section = rec[:section]
        section_title= rec[:section_title]
        body_system = rec[:body_system]
        body_system_title = rec[:body_system_title]
        root_operation = rec[:root_operation]
        root_operation_title = rec[:root_operation_title]

        body_part = rec[:body_part]
        body_part_title = rec[:body_part_title]

        approach = rec[:approach]
        approach_title = rec[:approach_title]

        device = rec[:device]
        device_title = rec[:device_title]

        qualifier = rec[:qualifier]
        qualifier_title = rec[:qualifier_title]

        long_description = rec[:long_description]

        print_element(icd10pcs_code <> " " <> long_description, "Description")
        print_element(section <> " " <> section_title, "Section")
        print_element(body_system <> " " <> body_system_title, "Body System")
        print_element(root_operation <> " " <> root_operation_title, "Operation")

        if body_part !== nil do
        print_element( body_part <> " " <>  body_part_title, "Body Part")
        end

       if  approach !== nil do
        print_element(approach <> " " <> approach_title, "Approach")
       end

        if device !== nil do
          print_element(device <> " " <> device_title, "Device")
        end

       if qualifier !== nil do
          print_element(qualifier <> " " <> qualifier_title, "Qualifier")
       end

        if is_header != nil do
          print_element(is_header, "Header")
        end

      end#for record

    else

        colorize_text("alert", "No Records Found")
    end#if any record
 
    response_options()

  end#show_pcs_record
  #####################
  


end##module
