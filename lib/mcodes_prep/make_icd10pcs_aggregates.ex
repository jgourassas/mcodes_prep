defmodule McodesPrep.MakeIcd10pcsAggregates do
  import SweetXml
  require Ecto.Query
  require Logger

  import McodesPrep.Utils

  def set_pcs_agg_xml_file do
    IO.gets("\t Location of ICD10-PCS DEFINITIONS XML file i.e: data/icd10pcs_definitions_2022.xml
    > ") |> String.trim()
  end

  ########################
  def pcs_agg_xml_file do
    pcs_agg_file = set_pcs_agg_xml_file()
    file_existance(pcs_agg_file)
  end

  ######################

  def pcs_agg_xml_list do
    pcs_agg_xml_file()
    |> xpath(
      ~x"//deviceAggregation"l,
      aggregate_l: [
        ~x".//aggregate"l,
        device: ~x"./device/text()"so,
        operation: ~x"./operation/text()"so,
        body_sys_l: [
          ~x".//bodySys"lo,
          body_sys: ~x"./text()"so
        ],

        # term_titles
        parent_value: ~x"./parent/@value"so,
        parent_text: ~x"./parent/text()"so
      ]

      # aggregete_l
    )
  end

  # xml_list
  ################
  def make_pcs_agg do
    colorize_text("default", "Im nearly Ready to Make icd10pcs_aggregates table")

    response = ask_user()

    case response do
      "Y" ->
        pcs_agg_as_list = pcs_agg_xml_list()
        Enum.each(pcs_agg_as_list, fn a_map -> insert_icd10pcs_agg(a_map) end)
        colorize_text("default", "Ok Thx ")

      "N" ->
        colorize_text("default", "---O.K. No Hard Fillings ---")

      _ ->
        colorize_text("alert", " --- Please Type Y or N --- ")
    end
  end

  # make_pcs_defs
  #######################
  def insert_icd10pcs_agg(map) do
    aggregate_l = map[:aggregate_l]

    Enum.each(aggregate_l, fn agg ->
      device = agg[:device]
      operation = agg[:operation]
      parent_text = agg[:parent_text]
      parent_value = agg[:parent_value]
      body_sys_l = agg[:body_sys_l]

      all_body_sys =
        Enum.reduce(body_sys_l, " ", fn x, acc ->
          %{body_sys: v} = x
          acc <> "^" <> v
        end)

      # Enum body_sys_l

      colorize_text("default", "#{device}")

      McodesPrep.Repo.insert(%McodesPrep.Icd10pcsAggegates{
        device: device,
        operation: operation,
        parent_text: parent_text,
        parent_value: parent_value,
        body_sys: all_body_sys
      })
    end)

    # Enum each aggregate_l
    colorize_text("alert", "---Finish -------------------------")
  end

  # insert_icd10pcs_agg

  #######################
  def search_pcs_aggregates do
    print_searching_in("Search ICD-10-PCS AGGREGATES File")
    device_field_q = get_response("Type a term as: Cardiac Lead Pacemaker ")

    device_q =
      Ecto.Query.from(p in McodesPrep.Icd10pcsAggegates,
        order_by: [asc: p.device],
        where: fragment("(?) @@ plainto_tsquery(?)", p.device, ^"#{device_field_q}%"),
        select: %{
          device: fragment("? ", p.device),
          operation: fragment(" ? ", p.operation),
          body_sys: fragment(" ? ", p.body_sys),
          parent_text: fragment(" ? ", p.parent_text),
          parent_value: fragment(" ? ", p.parent_value)
        },
        limit: 10
      )

    records_b = device_q |> McodesPrep.Repo.all()

    if Enum.any?(records_b) do
      IO.puts(" ")
      print_results_title(device_field_q)
      IO.puts(" ")

      Enum.map(records_b, fn rec ->
        device = rec[:device]
        opearion = rec[:operation]
        parent_text = rec[:parent_text]
        parent_value = rec[:parent_value]
        body_sys = rec[:body_sys]
        format_record(device)
        print_element(device, "Device")
        print_element(opearion, "Operation")
        print_element(body_sys, "Body System")
        print_element(parent_text, "Parent")
        print_element(parent_value, "Parent Value")
        IO.puts(" ")
      end)
    else
      colorize_text("alert", "Nothing Found")
    end

    response =
      get_response("Search Again in ICD-10-PCS Aggregates  File? [Y,N]") |> String.upcase()

    case response do
      "Y" ->
        search_pcs_aggregates()

      "N" ->
        colorize_text("default", "Ok. help for options, q to Quit")

      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end
  end

  ###############
  def format_record(title) do
    IO.puts(
      IO.ANSI.blue_background() <>
        IO.ANSI.white() <> " ❄❄❄ Device: #{title} ❄❄❄ " <> IO.ANSI.reset()
    )
  end

  ##############################
end

# module
