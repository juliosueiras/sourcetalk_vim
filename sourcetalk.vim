command Sourcetalk call s:Sourcetalk()

function! s:Sourcetalk()
	let title = expand('%:t')
	let content = join(getline(1,'$'),"\n")
	let url = "http://app.sourcetalk.net/conferences"
	let response = s:PostToST(title,content)
	if response.status == 201
		let body = webapi#json#decode(response.content)
		let html_url = url."/".body['guid']
		call s:OpenBrowser(html_url)
		echomsg "Posted: ".html_url
	else
		echohl WarningMsg | echomsg "Error" | echohl None
	endif
endfunction

function! s:PostToST(title,content)
	let request_uri = 'http://app.sourcetalk.net/conferences.json'
	let param = webapi#http#encodeURIComponent({"conference[file_name]":a:title,
					\"conference[source]":a:content,
					\"conference[scroll_position]":line(".")})
	let response = webapi#http#post(request_uri,param)
	return response
endfunction

function! s:OpenBrowser(url)
	if has('win32') || has('win64')
		let cmd = '!start rundll32 url.dll,FileProtocolHandler '.shellescape(a:url)
		silent! exec cmd
	elseif has('mac') || has('macunix') || has('gui_macvim')
	        let cmd = 'open '.shellescape(a:url)
		call system(cmd)
	elseif executable('xdg-open')
		let cmd = 'xdg-open '.shellescape(a:url)
		call system(cmd)
	elseif executable('firefox')
		let cmd = 'firefox '.shellescape(a:url).' &'
		call system(cmd)
	else
		echohl WarningMsg | echomsg "That's weird. It seems that you don't have a web browser." | echohl None
	endif
endfunction
