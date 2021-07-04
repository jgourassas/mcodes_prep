defmodule McodesPrep.SearchNdc do
  require Ecto.Query
  require Logger
  import McodesPrep.Utils
  alias McodesPrep.Utils, as: Utils
  # alias  McodesPrep.Ndc_product
  # alias  McodesPrep.Ndc_package
  def search_ndc_packages() do
    print_searching_in("Search NDC PACKAGES")
    term = get_response("To search NDC packages type a ndc product id as: 0597-0001 ")

    query =
      Ecto.Query.from(p in McodesPrep.Ndc_package,
        where: p.productndc == ^"#{term}",
        select: [p.packagedescription, p.ndcpackagecode],
        order_by: [asc: p.productid]
      )

    query2 =
      Ecto.Query.from(p in McodesPrep.Ndc_product,
        where: p.productndc == ^"#{term}",
        select: [p.proprietaryname],
        order_by: [asc: p.productid]
      )

    records = query |> McodesPrep.Repo.all()

    records2 = query2 |> McodesPrep.Repo.all()

    header = ["Package", "Package Code"]

    title = "Packages Result For #{term}. Product Name: #{records2}. Limited to 1 Records"

    if Enum.any?(records) do
      show_ndc_results(term, records, header, title)
    else
      colorize_text("alert", "Nothing Found")
    end

    # Enum.any

    response_options()
  end

  @spec search_ndc :: no_return
  def search_ndc() do
    print_searching_in("Search NDC")

    term = get_response("Type a Propriatary Name as: Aspirin, Aggrenox")

    query =
      Ecto.Query.from(p in McodesPrep.Ndc_product,
        order_by: [asc: p.proprietaryname],
        where:
          fragment("(?) @@ plainto_tsquery(?)", p.proprietaryname, ^"#{term}%") or
            fragment("(?) ilike(?)", p.substancename, ^"#{term}%"),
        select: [
          p.proprietaryname,
          p.dosageforname,
          p.substancename,
          p.active_numerator_strength,
          p.productndc
        ],
        limit: 25
      )

    records = query |> McodesPrep.Repo.all()
    header = ["Proprietary Name", "Form", "Subtance", "Strength", "Product ID"]
    title = "Results For #{term}. Limited to 12 Records and ordered by Prop Name"

    if Enum.any?(records) do
      show_ndc_results(term, records, header, title)
    else
      colorize_text("alert", "Nothing Found")
    end

    # Enum.any

    response_options()
  end

  # search_ndc

  def show_ndc_results(term, records, header, title) do
    _records_all =
      Enum.map(records, fn rec ->
        productndc = List.last(rec)
        packages = show_ndc_packages(productndc)
        rec ++ packages
      end)

    print_results_title(term)
    # Utils.present_tablerex(records_all, header, title)
    Utils.present_tablerex(records, header, title)
  end

  ###########################
  @spec response_options :: no_return
  def response_options() do
    response =
      get_response("Search in NDC Products Again? [Y,N] / Show Single Record [R]")
      |> String.upcase()

    case response do
      "Y" ->
        search_ndc()

      "R" ->
        show_ndc_record()

      # colorize_text("default", "Ok. Showing Record")
      # McodesPrep.Cli.loop()

      "N" ->
        colorize_text("default", "Ok. help for options")
        McodesPrep.Cli.loop()

      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end

    # case
  end

  # response_options
  #########################
  def show_ndc_record() do
    print_searching_in("Search AND SHOW NDC Record")
    code = get_response("Type a single Product ID as:  0597-0001 (Aggrenox)")

    query =
      Ecto.Query.from(p in McodesPrep.Ndc_product,
        where: p.productndc == ^"#{code}",
        select: %{
          productndc: p.productndc,
          producttypename: p.producttypename,
          proprietaryname: p.proprietaryname,
          proprietarynamesuffix: p.proprietarynamesuffix,
          nonproprietaryname: p.nonproprietaryname,
          dosageforname: p.dosageforname,
          routename: p.routename,
          startmarketingdate: p.startmarketingdate,
          endmargetingdate: p.endmargetingdate,
          marketingcategoryname: p.marketingcategoryname,
          applicationnumber: p.applicationnumber,
          labelname: p.labelname,
          substancename: p.substancename,
          active_numerator_strength: p.active_numerator_strength,
          active_ingred_unit: p.active_ingred_unit,
          pharm_classes: p.pharm_classes,
          deaschedule: p.deaschedule,
          ndc_exlude_flag: p.ndc_exlude_flag,
          listing_record_certified_through: p.listing_record_certified_through
        },
        limit: 1
      )

    record = query |> McodesPrep.Repo.all()
    print_results_title(code)

    if Enum.any?(record) do
      for rec <- record do
        # productndc = rec[:productndc]
        # proprietaryname= rec[:proprietaryname]
        productndc = rec[:productndc]
        producttypename = rec[:producttypename]
        proprietaryname = rec[:proprietaryname]
        #proprietarynamesuffix = rec[:proprietarynamesuffix]
        nonproprietaryname = rec[:nonproprietaryname]
        dosageforname = rec[:dosageforname]
        routename = rec[:routename]
        startmarketingdate = rec[:startmarketingdate]
        endmargetingdate = rec[:endmargetingdate]
        #marketingcategoryname = rec[:marketingcategoryname]
        #applicationnumber = rec[:applicationnumber]
        labelname = rec[:labelname]
        substancename = rec[:substancename]
        active_numerator_strength = rec[:active_numerator_strength]
        #active_ingred_unit = rec[:active_ingred_unit]
        pharm_classes = rec[:pharm_classes]
        deaschedule = rec[:deaschedule]
        #ndc_exlude_flag = rec[:ndc_exlude_flag]
        #listing_record_certified_through = rec[:listing_record_certified_through]

        print_element(
          "\n" <>
        " Product ID: " <>
           productndc <>
           "\n" <>
           " Proprietary Name: "  <>
            proprietaryname <>
            "\n" <>
            " Active Numerator strength: " <>
            active_numerator_strength <>
            "\n" <>
            " Substance Name: " <>
            substancename <>
            "\n" <>
            " labelname:  " <>
            labelname <>
            "\n" <>
            " Non Proprietary: " <>
            nonproprietaryname,
          " NDC "
        )

        print_element(
          "\n" <>
          " Dosage Name: " <>
            dosageforname <>
            "\n" <>
            " Route Name: " <>
            routename <>
            "\n" <>
            " Start Marketing Date: " <>
            startmarketingdate <>
            "\n" <>
            " End Marketing Date: " <>
            endmargetingdate <>
            "\n" <>
            " Product Typename: " <>
            producttypename <>
            " Dea chedule: " <>
            deaschedule ,
          "NDC PRODUCT"
        )

        print_element(
          " Pharmacological Classes: " <>
            pharm_classes,
          "Classes "
        )
      end

      # for
    else
      colorize_text("alert", "No Records Found")
    end

    # if

    response_options()
  end

  # end function

  #######################
  def show_pcs_record() do
    print_searching_in("Search In ICD-10-PCS Tabular Files For a Single Code")
    code = get_response("Type a single Code as:  5A1945Z, 5A1955Z, 5A1935Z, 0FB")

    query =
      Ecto.Query.from(p in McodesPrep.Icd10pcs,
        order_by: [asc: p.icd10pcs_code],
        where: p.icd10pcs_code == ^"#{code}",
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
          qualifier: p.qualifier,
          qualifier_title: p.qualifier_title
        },
        limit: 1
      )

    record = query |> McodesPrep.Repo.all()
    print_results_title(code)

    if Enum.any?(record) do
      for rec <- record do
        icd10pcs_code = rec[:icd10pcs_code]

        is_header = rec[:is_header]

        section = rec[:section]
        section_title = rec[:section_title]
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
          print_element(body_part <> " " <> body_part_title, "Body Part")
        end

        if approach !== nil do
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
      end

      # for record
    else
      colorize_text("alert", "No Records Found")
    end

    # if any record

    response_options()
  end

  # show_pcs_record
  #####################

  def show_ndc_packages(productndc) do
    query =
      Ecto.Query.from(p in McodesPrep.Ndc_package,
        where: p.productndc == ^"#{productndc}",
        select: [p.packagedescription],
        order_by: [asc: p.productid]
      )

    _records = query |> McodesPrep.Repo.all()

    # records_str = List.to_string(records)
    # records_replace  =  String.replace(records_str, ">", "\n")

    # _records_split = String.split(records_replace, "\n")

    # format_result =
    #  Enum.map(records_split, fn( item )  ->
    #    print_element(item, "Packages")
    # end)#Enum.map
  end

  # show_ndc_packages

  #####################
end

# module
