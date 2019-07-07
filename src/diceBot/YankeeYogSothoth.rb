# -*- coding: utf-8 -*-

class YankeeYogSothoth < DiceBot

  def initialize
    super
    @d66Type = 2
  end
  def gameName
    'ヤンキー＆ヨグ＝ソトース'
  end

  def gameType
    "YankeeYogSothoth"
  end

  def getHelpMessage
    return <<INFO_MESSAGE_TEXT
・判定
スペシャル／ファンブル／成功／失敗を判定
・各種表
※うろつき～決闘フェイズ
FT	ファンブル表
WT	変調表
RTT	ランダム特技決定表
KKT	関係表
DBRT	他愛のない会話表
TKT	戦う理由表

※武勇伝フェイズ
BUDT	武勇伝表
GUDT	ガイヤンキー武勇伝表
FTNT	二つ名表
DAIT	第一印象表
TKKT	ツレ関係表

※帰還フェイズ
GSST	現実世界生活表
GYST	ガイヤンキー生活表
HPST	病院生活表
・D66ダイスあり
INFO_MESSAGE_TEXT
  end

  # ゲーム別成功度判定(2D6)
  def check_2D6(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)

    return '' unless(signOfInequality == ">=")

    output =
      if(dice_n <= 2)
        " ＞ ファンブル(判定失敗。ファンブル表（FT）を振ること)"
      elsif(dice_n >= 12)
        " ＞ スペシャル(判定成功。【テンション】が１段階上昇)"
      elsif(total_n >= diff)
        " ＞ 成功"
      else
        " ＞ 失敗"
      end

    return output
  end


  def rollDiceCommand(command)
    string = command.upcase

    case string
    when 'RTT'   # ランダム特技決定表
      return getRandomSkillTableResult(command)
    end
    
    return getTableDiceCommandResult(command)
  end
  

  # 指定特技ランダム決定表
  def getRandomSkillTableResult(command)
    name = 'ランダム'

    skillTableFull = [
                      ['苦手', ['大人','勉強','敗北','昆虫','親','異性','孤独','高所','暗がり','ホラー','子供']],
                      ['部活', ['柔道','プロレス','テコンドー','空手','ボクシング','帰宅','剣道','野球','応援団','科学','文系']],
                      ['中学時代', ['悪ガキ','統一','バイト','習い事','喧嘩','サボり','マジメくん','遊び歩き','真似ごと','部活','何もしない']],
                      ['趣味', ['すけべ','車・バイク','家事','料理','運動','修行','ファッション','つるむ','寝る','ゲーム','読書']],
                      ['スタイル', ['テキトー','ばか','オラオラ','熱血','硬派','自然体','軟派','自分大好き','腹黒','クール','インテリ']],
                      ['好み', ['だらだら','食事','逆転','家族','支配','褒められる','恋愛','友情','勝利','金','静寂']],
                     ]

    skillTable, total_n = get_table_by_1d6(skillTableFull)
    tableName, skillTable = skillTable
    skill, total_n2 = get_table_by_2d6(skillTable)

    output = "#{name}指定特技表(#{total_n},#{total_n2}) ＞ 『#{tableName}』#{skill}"

    return output
  end
  
  
  def getTableDiceCommandResult(command)

    info = @@tables[command]
    return nil if info.nil?

    name = info[:name]
    type = info[:type]
    table = info[:table]

    text, number =
      case type
      when '2D6'
        get_table_by_2d6(table)
      when '1D6'
        get_table_by_1d6(table)
      when 'D66', 'D66S'
        table = getD66Table(table)
        get_table_by_d66_swap(table)
      else
        nil
      end

    return nil if( text.nil? )

    return "#{name}(#{number}) ＞ #{text}"
  end
  
  def getD66Table(table)
    table.map do |item|
      if item.kind_of?(String) and  /^(\d+):(.*)/ === item
        [$1.to_i, $2]
      else
        item
      end
    end
  end
  
  
  @@tables =
    {
    'FT' => {
      :name => "ファンブル表",
      :type => '1D6',
      :table => %w{
やっちまった……。テンションが1段階減少する。
ひょうなことから嫌な状況になる。ランダムに変調（WT）を1つ受ける。
あまりにもカッコ悪いところが伝わってしまう。自分に対して【友情度】を持つPC全員は、リスペクトにチェックを入れる。
自分の絶望を観測し、邪神が活性化する。バッドヤンキーの「ケツモチ邪神の加護」が1点上昇する。
つまらないことで怪我をする。自分の【HP】が1D6点減少する。
逆境に燃える。テンションが1段階上昇する。
},},
    
    'WT' => {
      :name => "変調表",
      :type => '1D6',
      :table => %w{
毒：サイクル終了時もしくはラウンド終了時に、2D6点のダメージを受ける。
呪い：熱血蘇生の達成値が2点減少する。NPCが受けた場合、受けるダメージが2点上昇する。
火傷：テンションの効果によって、【攻撃力】が上昇しない。NPCは【攻撃力】が2点低いものとして扱う（最低０点）。
骨折：判定に失敗するたびに、5点のダメージを受ける。
出血：サイクル終了時もしくはラウンド終了時に、2点のダメージを受ける。また、施設やアイテムの効果で【HP】が上昇しない。
目つぶし：判定の達成値が2点減少する。
},},

    'KKT' => {
      :name => "関係表",
      :type => '1D6',
      :table => %w{
「家族／気に食わない」
「親友／近寄るな」
「悪友／こざかしい」
「ライバル／チンピラ」
「いい奴／悪い奴」
「利用できる／ヘタレ」
},},

    'DBRT' => {
      :name => "他愛のない会話表",
      :type => 'D66',
      :table => %w{
11:「政治の話」
12:「勉強の話」
13:「友達の話」
14:「兄弟姉妹の話」
15:「好きなものの話」
16:「嫌いなものの話」
22:「ラーメンの話」
23:「コンビニの話」
24:「学校生活の話」
25:「先輩後輩の話」
26:「趣味の話」
33:「肉の話」
34:「中学時代の話」
35:「喧嘩の話」
36:「ファッションの話」
44:「家の話」
45:「好みの異性の話」
46:「テレビ番組の話」
55:「野菜の話」
56:「部活の話」
66:「ダブりの話」
},},

    'TKT' => {
      :name => "戦う理由表",
      :type => 'D66',
      :table => %w{
11:「なんとなく」
12:「好みのエルフがいた」
13:「エルフに世話になった」
14:「ドワーフの飯がうまかった」
15:「ドワーフにファッション特徴を作ってもらった」
16:「妖精たちのいたずらがほほえましかった」
22:「バッドヤンキーと昔からの因縁があるから」
23:「バッドヤンキーが気に入らなかった」
24:「強いやつと戦いたい」
25:「異世界にワクワクしているから」
26:「バッドヤンキー集団に迷惑を受けたから」
33:「夢見るNPCが好みだったから」
34:「夢見るNPCの夢に共感したから」
35:「夢見るNPCの夢を応援したいと思ったから」
36:「夢見るNPCを放っておけないから」
44:「家に帰りたいから」
45:「夢見るNPCは友達だから」
46:「他のPCと気が合ったから」
55:「マーメイドと仲良くなった」
56:「退屈を紛らわせられそうだから」
66:「ただ暴れたかった」
},},

    'BUDT' => {
      :name => "武勇伝表",
      :type => 'D66',
      :table => %w{
11:バッドヤンキーのチームに自分が所属する学校を破壊されたが、最後まで戦った。／テンションが1段階上昇
12:バッドヤンキーチームの兵隊が襲い掛かってきたが、撃退した。／【HP】＋３
13:バッドヤンキーと何度も戦い、ライバルとして認識されていた。／【打たれ強さ】＋１
14:バッドヤンキー配下の集団をいくつか潰してまわっていた。／【攻撃力】＋１
15:バッドヤンキーのチームに入りそうになった後輩を説得した。／【HP】＋３
16:バッドヤンキーに支配されていた店を救った。／【攻撃力】＋１
22:アメリカで暴れた。／テンションが1段階上昇
23:学校をサボって、日本全国を旅をしてまわった。／【HP】＋３
24:好きなアーティストのライブに行き、マナーの悪いファンを黙らせた。／【打たれ強さ】＋１
25:抗争中の学校に一人で乗り込んで、戦いを終わらせた。／【攻撃力】＋１
26:へまをした仲間を助けるため、頭を下げた。／【HP】＋３
33:大規模な運動会で活躍し、最優秀賞を獲得した。／【攻撃力】＋１
34:家族や仲間に迷惑をかけたチームを潰した。／【打たれ強さ】＋１
35:暴走族を一人で潰した。／【攻撃力】＋１
36:本職（ヤクザ）と戦って謝らせた。／【打たれ強さ】＋１
44:ドッジボール大会に出場し、優勝をして賞品を手に入れた。／「絆創膏」「テンアゲアイテム」「ポーション」「お守り」のうち１つを選んで獲得する
45:仲間たちと一緒に学校行事を盛り上げた。／【打たれ強さ】＋１
46:仲間と一緒にディスカウントストアで買い物をし、キャンプをした。／「絆創膏」「テンアゲアイテム」「ポーション」「お守り」のうち１つを選んで獲得する
55:隣のプレイヤーのPCが所属する高校と大きな抗争をした。／右隣のプレイヤーのPCに対する【友情度】が1点上昇
56:修学旅行先で喧嘩し、その後友情を深めた。／【攻撃力】＋１
66:隣のプレイヤーのPCと一緒に、大きな悪の組織を潰した。／右隣のプレイヤーのPCに対する【友情度】が1点上昇
},},

    'GUDT' => {
      :name => "ガイヤンキー武勇伝表",
      :type => 'D66',
      :table => %w{
11:アザトースが突然接触してきたので、殴って追い返した。／テンションが1段階上昇
12:シュブ＝ニグラスのサバトに乗り込んで潰した。／【HP】＋３
13:クトゥルフの落とし子を殴り倒して追い返した。／【打たれ強さ】＋１
14:ヨグ=ソトースの勧誘を受けたが、断ってやった。／【攻撃力】＋１
15:深きものどもが住む漁村を訪ね、罠にはめられたが脱出した。／【HP】＋３
16:一晩飲み明かした相手がナイアーラトテップだった。／【攻撃力】＋１
22:生きてる恐竜と出会った。／テンションが1段階上昇
23:ファンタジー世界を冒険者として旅してまわった。／【HP】＋３
24:町で起こった少女たちの失踪事件を解決した。／【打たれ強さ】＋１
25:バッドヤンキーに潰された騎士団を鼓舞して、立て直しに協力した。／【攻撃力】＋１
26:大きな城下町に起こった殺人事件や傷害事件を幾つも解決した。／【HP】＋３
33:大きな城下町で、テンションが上がっていろいろ買い込んでしまった。／「絆創膏」「テンアゲアイテム」「ポーション」「お守り」のうち１つを選んで獲得する
34:エルフの森を燃やしつくそうとする拝火暴走族をこらしめた。／【打たれ強さ】＋１
35:ドワーフの洞窟に現われた巨大ワームを投げ飛ばした。／【攻撃力】＋１
36:妖精たちの村に迷い込んで、村を荒らそうとするゴブリンをブッ飛ばした。／【打たれ強さ】＋１
44:巨大な王国が主催している武術大会で優勝し、名誉とアイテムを手に入れた。／「絆創膏」「テンアゲアイテム」「ポーション」「お守り」のうち１つを選んで獲得する
45:ゴブリンの襲撃から町を守り切った。／【打たれ強さ】＋１
46:悪いチームにさらわれた姫や王子様を助けたら、惚れられた。／【攻撃力】＋１
55:次に会うヤンキーのために、この世界の土産話を作ってきた。／右隣のプレイヤーのPCに対する【友情度】が1点上昇
56:悪い魔法使いの儀式を突き止めて、潰した。／【攻撃力】＋１
66:次に会うヤンキーのために、うまいものを用意した。／右隣のプレイヤーのPCに対する【友情度】が1点上昇
},},

    'DAIT' => {
      :name => "第一印象表",
      :type => '1D6',
      :table => %w{
「ヤベエ」
「パネエ」
「スゲエ」
「びっくり」
「たばい」
「アウトオブ眼中」
},},

    'TKKT' => {
      :name => "ツレ関係表",
      :type => '1D6',
      :table => %w{
「すごそう」
「勇者様」
「つよい」
「いい人」
「かっこいい」
「利用できる」
},},

    'GSST' => {
      :name => "現実世界生活表",
      :type => 'D66',
      :table => %w{
11:喧嘩に明け暮れた
12:真面目に授業を受けた
13:今回の仲間と食事をしに行った
14:チーム同士の抗争を沈めた
15:ぼーっとしていた
16:バイトに専念した
22:仲間とバーベキューをした
23:自分の体を鍛えることにした
24:仲間との毎日をより大切にした
25:家族とゆっくりすごした
26:喧嘩の技術を磨いた
33:本職（ヤクザ）と喧嘩をした
34:好きなだけ寝た
35:ツレができた
36:今回の仲間と旅に出た
44:異性と遊園地に行くことになった
45:あの戦いの日々を思い返していた
46:次の戦いに備えた
55:運動部の助っ人として、大会に出た
56:好きなだけ好物を食べた
66:汚い大人の罠にはめられたが、なんとかした
},},

    'GYST' => {
      :name => "ガイヤンキー生活表",
      :type => 'D66',
      :table => %w{
11:ツレと生活をした
12:異世界について学んだ
13:エルフの美形（平均年齢200歳）に接待を受けた
14:ドワーフから地元の酒をもらった
15:妖精の村に迷い込んでしまった
16:この世界の遺跡を回った
22:この世界に野球などのスポーツを広めた
23:広大な森の中で迷ってしまい、数か月ほどサバイバルした
24:不思議な力が溢れる泉の水を飲み干した
25:魔法使いの研究に協力したが、さっぱりだった
26:ハーピィに誘われて空の旅を満喫した
33:この世界にヤンキー文化を伝えた
34:バッドヤンキーに荒らされた小さな村を復興した
35:悪徳領主にさらわれた少女を助けた
36:わるい商人を殴り飛ばした
44:エルフの漫画家が誕生するのを見届けた
45:巨大なドラゴンと殴りあって勝利した
46:海中に住むマーメイドを脅かす悪人を退治した
55:邪神を信奉している神殿に殴り込みをして、企みを阻止した
56:天使っぽいのが悪いことをしていたので蹴り飛ばした
66:農作業をした
},},

    'HPST' => {
      :name => "病院生活表",
      :type => '1D6',
      :table => %w{
11:治療に専念した
12:見舞いでもらった漫画を読み倒した
13:ゲームをひたすらやった
14:悪化した病と闘った
15:入院している子供と約束をした
16:看護師と仲良くなった
22:現代の医術では治療できなかったので、異世界の魔法に賭けた
23:院内パーティを盛り上げた
24:飯がまずくて苦労した
25:飯がうまくて感動をした
26:やることがなくて暇だった
33:スーパードクターが現われて、自分の怪我を見事に治してくれた
34:とにかくテレビを見続けて、知識がついた
35:勉強をしてみたら、いつも以上にはかどった
36:たくさんの人たちが見舞いに来て、感動した
44:入院をしている爺さんから色々教えてもらった
45:リハビリに思ったより時間がかかった
46:次に喧嘩するときのイメージトレーニングをした
55:ヤンキー漫画に感動をした
56:院内で喧嘩をした
66:売店で売っているお菓子をコンプリートした
},},
  }
  
  setPrefixes(['RTT'] + @@tables.keys)
end
