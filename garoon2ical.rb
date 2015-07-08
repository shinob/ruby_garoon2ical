# -*- encoding: utf-8 -*-

require 'rubygems'
require 'httpclient'
require 'date'

# iCalデータ編集

def make_ics(str, dt, first)

  y = dt.year
  m = dt.month
  
  flg = true
  cnt = 0
  
  ics = ""
  
  if first then
    ics = <<EOF
BEGIN:VCALENDARa
PRODID:Cybozu Web Calendar
VERSION:2.0
EOF
  end
  
  dtstart = "DTSTART:#{sprintf("%4d%02d",y,m)}"
  
  flg_desc = false
  
  str.each_line do |line|
    
    if cnt < 3 then
      
      # 初めの3行は読込まない
      
    elsif flg_desc then
      
      if /^END:/ =~ line then
        # ENDデータの読込
        flg_desc = false
        ics += "\n" + line
      else
        # DESCRIPTIONでは改行コードを文字列に変換
        ics += line.gsub("\n","\\n")
      end
      
    elsif /^DESC/ =~ line && flg then
      
      # DESCRIPTIONデータの加工
      flg_desc = true
      ics += line.gsub("\n","\\n")
      
    elsif /[A-Z]/ =~ line then
      
      if line == "BEGIN:VEVENT\n" || line == "END:VCALENDAR" then
        
        # データ開始行、データ終了行を読込まない
        flg = false
        
      elsif line[0..(dtstart.length-1)] == dtstart then
        
        # 日付が指定月のデータであれば読込開始
        flg = true
        ics += "BEGIN:VEVENT\n" + line
        
      else
        
        # データ読込
        if flg then
          ics += line
        end
        
      end
      
    end
    
    cnt += 1
    
  end
  
  return ics
  
end


# ガルーンにログインする
loginURL = 'http://[your garoon url]/cgi-bin/cbgrn/grn.cgi/'

loginParams = {
  '_system' => '1',
  '_account' => '[your account]',
  '_password' => '[your password]'
}

client = HTTPClient.new()
client.post(loginURL, loginParams)

# 当月と翌月を取得する

now = Time.new

thisMonth = Date.new(now.year, now.month, 1)
nextMonth = thisMonth >> 1
next2Month = thisMonth >> 2

# iCalデータ取得用URL

iCalURL = "#{loginURL}schedule/command_personal_month_icalexport"

# ユーザー情報の設定

users = [
  {
    "name" => "[user name]",
    "uid" => "000",
    "gid" => "000"
  },
  {
    "name" => "[user name]",
    "uid" => "000",
    "gid" => "000"
  }
]

users.each do |row|
  
  str = ""
  
  open("./#{row["name"]}.ics","w") do |f|
    
    puts row["name"]
    
    # 1ヶ月目のiCalデータ
    tmp = client.get_content("#{iCalURL}?uid=#{row["uid"]}&gid=#{row["gid"]}&bdate=#{thisMonth.to_s}")
    str += make_ics(tmp, thisMonth, true)
    
    # 2ヶ月目のiCalデータ
    tmp = client.get_content("#{iCalURL}?uid=#{row["uid"]}&gid=#{row["gid"]}&bdate=#{nextMonth.to_s}")
    str += make_ics(tmp, nextMonth, false)
    
    # 3ヶ月目のiCalデータ
    tmp = client.get_content("#{iCalURL}?uid=#{row["uid"]}&gid=#{row["gid"]}&bdate=#{next2Month.to_s}")
    str += make_ics(tmp, next2Month, false)
    
    str += "END:VCALENDAR\n"
    
    f.write str
    
  end
  
end

