module BooksHelper
    def systemid_display_name(systemid)
      city_names = {
        'Osaka_Osaka' => '大阪市',
        'Osaka_Sakai' => '堺市',
        'Osaka_Kishiwada' => '岸和田市',
        'Osaka_Toyonaka' => '豊中市',
        'Osaka_Ikeda' => '池田市',
        'Osaka_Suita' => '吹田市',
        'Osaka_IzumiOtsu' => '泉大津市',
        'Osaka_Takatsuki' => '高槻市',
        'Osaka_Kaizuka' => '貝塚市',
        'Osaka_Moriguchi' => '守口市',
        'Osaka_Hirakata' => '枚方市',
        'Osaka_Ibaraki' => '茨木市',
        'Osaka_Yao' => '八尾市',
        'Osaka_IzumiSano' => '泉佐野市',
        'Osaka_Tondabayashi' => '富田林市',
        'Osaka_Neyagawa' => '寝屋川市',
        'Osaka_Kawachinagano' => '河内長野市',
        'Osaka_Matsubara' => '松原市',
        'Osaka_Daito' => '大東市',
        'Osaka_Izumi' => '和泉市',
        'Osaka_Minoh' => '箕面市',
        'Osaka_Kashiwara' => '柏原市',
        'Osaka_Habikino' => '羽曳野市',
        'Osaka_Kadoma' => '門真市',
        'Osaka_Setsuto' => '摂津市',
        'Osaka_Takaishi' => '高石市',
        'Osaka_Fujidera' => '藤井寺市',
        'Osaka_Higashiosaka' => '東大阪市',
        'Osaka_Sennan' => '泉南市',
        'Osaka_Shirodawate' => '四條畷市',
        'Osaka_Katano' => '交野市',
        'Osaka_Osakasayama' => '大阪狭山市',
        'Osaka_Hannan' => '阪南市',
        'Osaka_Shimamoto' => '島本町',
        'Osaka_Toyono' => '豊能町',
        'Osaka_Nose' => '能勢町',
        'Osaka_Tadaoka' => '忠岡町',
        'Osaka_Kumatori' => '熊取町',
        'Osaka_Tajiri' => '田尻町',
        'Osaka_Misaki' => '岬町',
        'Osaka_Taishi' => '太子町',
        'Osaka_Chihayaakasaka' => '千早赤阪村'
      }
      city_names[systemid] || systemid.gsub('Osaka_', '').gsub('_', ' ')
    end
  
    def library_display_name(lib_name)
      lib_name.gsub('_', ' ').gsub('Osaka Pref', '大阪府').gsub('Osaka', '大阪市').gsub('Sakai', '堺市').gsub('Kishiwada', '岸和田市').gsub('Toyonaka', '豊中市').gsub('Ikeda', '池田市').gsub('Suita', '吹田市')
    end
  end