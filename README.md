# gemini_grav
🚀 Grav CMS + Gemini AI Blog Automation

Generate SEO-optimized Markdown pages with AI in seconds!

✨ Features:
• Full YAML frontmatter (title, menu, description, keywords)
• Auto slug/menu generation  
• UTF-8 support (Cyrillic/any language)
• SSH/SCP upload to remote Grav site
• PowerShell script, Windows ready

⚡ Usage: 
./new-post.ps1 -Title "My Post" -Prompt "Write about..." -ServerUser root -ServerIP 1.2.3.4
Example:
 .\new-post.ps1 `
>>   -Title "Best Blog" `
>>   -Prompt "Write a 300-character welcome post for "The Best Blog on Earth". Tone: bold, energetic, and magnetic. Include a killer headline, a one-sentence mission statement (why we are the best), and a punchy CTA. No clichés." `
>>   -ServerUser "root" `
>>   -ServerIP "example.ru" `
>>   -Port 22 `
>>   -ParentFolder "01.home"

Work folder: /opt/grav-site/site-data/www/user/pages/

Perfect for automated blogs, whitepapers, tech articles. 
Just provide title/prompt → get production-ready page!

⭐ Star if useful for your Grav workflow!




