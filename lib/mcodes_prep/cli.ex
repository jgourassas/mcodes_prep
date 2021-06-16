defmodule McodesPrep.Cli do

  import McodesPrep.Utils

  alias McodesPrep.{
    MakeIcd10cm,
    MakeIcd10pcs,
    Utils,
    MakeIcd10pcsIndex,
    MakeIcd10pcsDefs,
    MakeIcd10pcsAggregates,
    MakeIcd10cmNeoplasms,
    MakeIcd10cmIndex,
    MakeIcd10cmEindex,
    MakeIcd10cmDindex,
    MakeCtd
   
  }



  def main(_) do
    say_message("Transform ICD-10 XML files to  Postgresql Tables and then Search (by J.G.)")
    say_message("Type help / h for the available commands. q To Quit")
    if IO.ANSI.enabled?() == false do
      colorize_text("alert", "Please Enable IO.ANSI")
    end

    loop()
  end

  def loop do
    input = IO.gets("\t > ") |> String.trim |> String.downcase
    process(input)
    loop()
  end

  def process(input) do
    case input do
      "cm2pg" -> cm2pg()
      "cms" -> cm_search()
      "cmvsr" -> cmvsr_search()
      "cmns" -> cmns_search()
      "cminds" -> cmind_search()
      "cmeinds" -> cmeind_search()
      "cmdinds" -> cmdind_search()
      "ctds" -> ctd_search()
      "pcs2pg" -> pcs2pg()
      "pcss" -> pcs_search()
      "pcsinds" -> pcs_index_search()
      "pcsds" -> pcs_defs_search()
      "pcsas" -> pcs_agg_search()
      "pcsvsr" -> pcsvsr_search()
      "help" -> print_help()
      "h"    -> print_help()
      "exit" -> stop()
      "q" -> stop()
      "" -> :noop # ignore
        _ -> IO.puts "Unknown command : #{input}"
    end
  end

  def stop() do
    System.halt()
  end

  def cm2pg() do
    MakeIcd10cm.make_alternative()
    #MakeIcd10cm.make_cm_orders()
    #MakeIcd10cm.make_cm_diagnosis()
    #MakeIcd10cm.make_chapters()
    MakeIcd10cm.make_cm_json()
    MakeIcd10cmNeoplasms.make_neoplasm()
    MakeIcd10cmIndex.make_cm_index()
    MakeIcd10cmEindex.make_cm_eindex()
    MakeIcd10cmDindex.make_dindex

  end

  def pcs2pg do
    MakeIcd10pcs.make_pcs_orders()
    MakeIcd10pcs.make_all_pcs_set_axis_fields()
    MakeIcd10pcs.make_all_pcs_set_axis_titles()
    MakeIcd10pcsIndex.make_pcs_index()
    MakeIcd10pcsDefs.make_pcs_defs()
    MakeIcd10pcsAggregates.make_pcs_agg()
  end

  def cm_search() do
    MakeIcd10cm.search_icd10cm()
  end


  def cmvsr_search() do
    MakeIcd10cm.show_record()
  end

  def pcs_search() do
    MakeIcd10pcs.search_pcs()
  end


  def pcsvsr_search() do
    MakeIcd10pcs.show_pcs_record()
  end

  def pcs_index_search() do
    MakeIcd10pcsIndex.search_pcs_index()
  end
  def pcs_defs_search() do
    MakeIcd10pcsDefs.search_pcs_defs()
  end

  def pcs_agg_search() do
    MakeIcd10pcsAggregates.search_pcs_aggregates()                  
  end

  def cmind_search do
    MakeIcd10cmIndex.search_cm_index()
  end

  
  def cmns_search do
    MakeIcd10cmNeoplasms.search_cm_neoplasms()
  end

  def cmeind_search do
    MakeIcd10cmEindex.search_cm_eindex()
  end
  def cmdind_search do
    MakeIcd10cmDindex.search_dindex()
  end

  def ctd_search do
    MakeCtd.search_ctd()
  end




  def print_help do
    IO.ANSI.clear()
    IO.puts IO.ANSI.blue_background() <> IO.ANSI.white()
    <> " \u25A3 \u0391\u03A9 -------------- \u25C9   List of available commands \u25C9 -------------- \u25A3 " <> IO.ANSI.reset
    Utils.colorize_text("default",  "
    * -------Store Files In PG ----------------------------------------*
    * cm2pg   : ICD-10-CM  To Postgresql
    * pcs2pg  : ICD-10-PCS To Postgresql DB
    * ------- Search cm[ICD-10-CM], s[Search] -----------------------*
    * cminds  : cm ind[Alphabetic Index] s[Search]. Search Main Term
    * cms     : cm s[Search] Tabular List
    * cmvsr   : cm v[View] s[Single] r[Record]. View all Record giving the Code
    * cmns    : cm n[Neoplasms] s[Search]
    * cmeinds : cm e[External] ind[Index] s[Search]
    * cmdinds : cm d[Drug] ind[Index] s[Search]
    * ctds    : c[Comparative] t[Toxicogenomics] d[Database] s[Search]
    * ------- Search In pcs[ICD-10-PCS], s[Serch]-----------------------------------*
    * pcss    : pcs s[Search]
    * pcsvsr  : pcs v[View]  s[Single] r[Record]. Search giving a Code 
    * pcsinds : pcs ind[Index] s[Search]
    * pcsds   : pcs d[Definitions] s[Search]
    * pcsas   : pcs a[Aggregates] s[Search]
    * -----------------------------------------------------------------*
    * help / h : print this message
    * exit / q : exit this application
    * -----------------------------------------------------------------*
    ")

  end




end
