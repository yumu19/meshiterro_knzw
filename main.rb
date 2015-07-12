# encoding: utf-8
require 'twitter'
require 'open-uri'
require 'json'
require 'yaml'

config = YAML.load_file('config.yml')
$keyid = config["gurunavi"]["keyid"]

twitter_client = Twitter::REST::Client.new do |c|
  c.consumer_key = config["twitter"]["consumer_key"]
  c.consumer_secret = config["twitter"]["consumer_secret"]
  c.access_token = config["twitter"]["access_token"]
  c.access_token_secret = config["twitter"]["access_token_secret"]
end

def getInfo(filename)
  gotten = false
  lines = File.read(filename).count("\n")
  id = "0"
  until gotten do
    randid = rand(lines)
    open(filename) {|file|
      id = file.readlines[randid].chomp
    }
    gu = "http://api.gnavi.co.jp/PhotoSearchAPI/20150630/?keyid=#{$keyid}&format=json&shop_id=#{id}"
    gu_res = open(gu)
    p gu
    j = JSON.parse(gu_res.read())

    if(j.include?("response")) then
      j["response"]["0"]["photo"]
      photo_url = j["response"]["0"]["photo"]["image_url"]["url_1024"]
      menu_name = j["response"]["0"]["photo"]["menu_name"]
      shop_name = j["response"]["0"]["photo"]["shop_name"]
      shop_url = j["response"]["0"]["photo"]["shop_url"]
      gotten = true
    end
  end
  return {"photo_url"=>photo_url, "menu_name"=>menu_name, "shop_name"=>shop_name, "shop_url"=>shop_url}
end

$g = Hash.new
hashtag = "#飯テロ金沢 画像提供：ぐるなび"

randamize = rand(5)
case randamize
when 0 then
  $g["photo_url"] = "./img/8ban.jpg"
  $g["shop_name"] = "8番らーめん 辰口店 "
  $g["shop_url"] = "http://r.gnavi.co.jp/mc7rtejg0000/"
  str1 = "国道８号線沿いで開業したから８番らしいで
  #{$g["shop_name"]} #{$g["shop_url"]} #{hashtag}"
when 1 then
  $g = getInfo("curry.txt")
  str1 = "ステンレスの皿に盛られてて、フォークか先割れスプーンで食べるんやで。キャベツの付け合わせも特徴やで
  #{$g["shop_name"]} #{$g["menu_name"]} #{$g["shop_url"]} #{hashtag}"
when 2 then
  $g["photo_url"] = "./img/hanton.jpg"
  $g["shop_name"] = "グリルオーツカ"
  $g["shop_url"] = "http://r.gnavi.co.jp/awfdk2yu0000"

  str1 = "ハントンのハンは，ハンガリーのハンなんやで
  #{$g["shop_name"]} #{$g["shop_url"]} #{hashtag}"
when 3 then
    $g = getInfo("ids.txt")
    str1 = "#{$g["shop_name"]} の #{$g["menu_name"]} めっちゃうま〜〜〜！ #{$g["shop_url"]} #{hashtag}"
else
  $g = getInfo("ids.txt")
  str1 = "今、#{$g["menu_name"]} 食べに、#{$g["shop_name"]}に来てんねんけどな、、、どうよ？ #{$g["shop_url"]} #{hashtag}"
end

p str1
open($g["photo_url"]) do |tmp|
    twitter_client.update_with_media(str1, tmp)
end
