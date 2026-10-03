::  %groups-mcp: MCP resource server for Tlon channels.
::
::    %wicket issues the token. This agent decides which channels that
::    token may see. Reads scry %groups and %channels. Writes poke
::    %channels with %channel-action-2. Creates poke %groups with
::    %group-command and %channels with %channel-action-2. A read
::    never marks a channel read.
::
/-  wicket
/+  default-agent, dbug, server, verb
/+  wicket-check, g=groups-mcp
|%
+$  versioned-state
  $:  %0
      policy=(map @t group-policy:g)
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
^-  agent:gall
=|  versioned-state
=*  state  -
%+  verb  |
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  [%pass /eyre %arvo %e %connect [~ /groups-mcp] dap.bowl]
      [%pass /register %agent [our.bowl dap.bowl] %poke %noun !>(~)]
  ==
++  on-save  !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  =/  prev  !<(versioned-state old)
  :_  this(state prev)
  ~[self-poke:~(. work [bowl prev])]
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =/  hc  ~(. work [bowl state])
  ?+  mark  (on-poke:def mark vase)
      %noun
    [register:hc this]
  ::
      %handle-http-request
    =^  cards  state  (handle-http:hc !<([@ta inbound-request:eyre] vase))
    [cards this]
  ==
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
      [%http-response @ ~]  `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%eyre %bound *] sign-arvo)
    (on-arvo:def wire sign-arvo)
  ?:  accepted.sign-arvo  `this
  ~&  [%groups-mcp %bind-failed binding.sign-arvo]
  `this
++  on-fail  on-fail:def
--
|%
++  work
  |_  [=bowl:gall state=versioned-state]
++  self-poke
  [%pass /register %agent [our.bowl dap.bowl] %poke %noun !>(~)]
::
++  origin-now
  ^-  (unit @t)
  =/  run
    %-  mule
    |.  .^(@t %gx /(scot %p our.bowl)/wicket/(scot %da now.bowl)/origin/noun)
  ?:  ?=(%| -.run)  ~
  ?:  =('' p.run)  ~
  `p.run
::
++  audience
  |=  org=@t
  (rap 3 org '/groups-mcp' ~)
::
++  register
  ^-  (list card)
  =/  org  origin-now
  ?~  org
    %-  (slog leaf/"groups-mcp: %wicket origin is unset" ~)
    ~
  =/  url=@t  (audience u.org)
  =/  rec=registered-resource:wicket
    [url %groups-mcp (silt all:g) url]
  :~  :*  %pass  /wicket/reg
          %agent  [our.bowl %wicket]
          %poke  %wicket-action
          !>(`action:wicket`[%register-resource rec])
      ==
      :*  %pass  /wicket/copy
          %agent  [our.bowl %wicket]
          %poke  %wicket-action
          !>(`action:wicket`[%set-scope-copy url copy:g])
      ==
  ==
::
++  gx-json
  |=  [dude=@tas rest=path]
  ^-  (unit json)
  =/  run
    %-  mule
    |.
    .^  json
      %gx
      (weld /(scot %p our.bowl)/[dude]/(scot %da now.bowl) rest)
    ==
  ?:(?=(%| -.run) ~ `p.run)
::
++  groups-now  (gx-json %groups /groups/json)
++  channels-now  (gx-json %channels /v1/channels/json)
::
++  holds
  |=  [have=(list @t) need=@t]
  (lien have |=(s=@t =(s need)))
::
++  admit
  |=  req=inbound-request:eyre
  ^-  $%  [%down ~]  [%no ~]  [%yes scopes=(list @t)]  ==
  ?:  ?&  authenticated.req
          =(src.bowl our.bowl)
      ==
    [%yes all:g]
  =/  tok  (bearer:wicket-check header-list.request.req)
  ?~  tok  [%no ~]
  =/  org  origin-now
  ?~  org  [%down ~]
  =/  run
    %-  mule
    |.
    .^  (unit grant:wicket)
      %gx
      /(scot %p our.bowl)/wicket/(scot %da now.bowl)/grant/(scot %t u.tok)/noun
    ==
  ?:  ?=(%| -.run)  [%down ~]
  ?~  p.run  [%no ~]
  ?.  =(`(audience u.org) resource.u.p.run)  [%no ~]
  [%yes scopes.u.p.run]
::
++  json-pay
  |=  [eyre-id=@ta code=@ud jon=json extra=header-list:http]
  ^-  (list card)
  %+  give-simple-payload:app:server
    eyre-id
  :-  :-  code
      (weld extra ['content-type' 'application/json']~)
  `(as-octt:mimes:html (trip (en:json:html jon)))
::
++  html-pay
  |=  [eyre-id=@ta code=@ud text=tape]
  ^-  (list card)
  %+  give-simple-payload:app:server
    eyre-id
  :-  :-  code
      ~[['content-type' 'text/html; charset=utf-8']]
  `(as-octt:mimes:html text)
::
++  mcp-version  %'2025-06-18'
::
++  tool-result
  |=  [id=@ta text=@t]
  ^-  json
  %-  pairs:enjs:format
  :~  ['id' n+id]
      ['jsonrpc' s+'2.0']
      :-  'result'
      %-  pairs:enjs:format
      :~  :-  'content'
          :-  %a
          :~  %-  pairs:enjs:format
              :~  ['type' s+'text']
                  ['text' s+text]
              ==
          ==
          ['isError' b+|]
      ==
  ==
::
++  rpc-err
  |=  [id=@ta code=@ta msg=@t]
  %-  pairs:enjs:format
  :~  ['id' n+id]
      ['jsonrpc' s+'2.0']
      :-  'error'
      %-  pairs:enjs:format
      :~  ['code' n+code]
          ['message' s+msg]
      ==
  ==
::
++  tool-desc
  ^-  (list [name=@t scope=@t desc=@t schema=json])
  :~  :-  %'list-channels'
      :-  scope-list:g
      :-  'Channels the ship owner has exposed. Each row has nest, group, title, kind, and access (read or write). Unconfigured groups are omitted.'
      %-  pairs:enjs:format
      :~  ['type' s+'object']
          ['properties' (pairs:enjs:format ~)]
      ==
    ::
      :-  %'read-posts'
      :-  scope-read:g
      :-  'Newest posts in one chat channel the policy allows reading. Text is flattened from the story document. Does not mark the channel read. Diary and gallery channels are refused.'
      %-  pairs:enjs:format
      :~  ['type' s+'object']
          :-  'properties'
          %-  pairs:enjs:format
          :~  :-  'nest'
              (pairs:enjs:format ['type' s+'string'] ['description' s+'chat/~ship/name'] ~)
              :-  'count'
              (pairs:enjs:format ['type' s+'number'] ['description' s+'1 to 50, default 20'] ~)
          ==
          ['required' a+~[s+'nest']]
      ==
    ::
      :-  %'add-post'
      :-  scope-write:g
      :-  'Post plain text to a chat channel the policy allows writing, as this ship. The channel writers set in %channels still applies.'
      %-  pairs:enjs:format
      :~  ['type' s+'object']
          :-  'properties'
          %-  pairs:enjs:format
          :~  :-  'nest'
              (pairs:enjs:format ['type' s+'string'] ~)
              :-  'text'
              (pairs:enjs:format ['type' s+'string'] ~)
          ==
          ['required' a+~[s+'nest' s+'text']]
      ==
    ::
      :-  %'create-group'
      :-  scope-create:g
      :-  'Create a group hosted by this ship and open it to MCP clients at write. The name is a term and becomes ~ship/name. Privacy defaults to secret. Does not create a channel; list-channels stays empty until one exists.'
      %-  pairs:enjs:format
      :~  ['type' s+'object']
          :-  'properties'
          %-  pairs:enjs:format
          :~  :-  'name'
              (pairs:enjs:format ['type' s+'string'] ['description' s+'lowercase letters, digits, and hyphens, not starting with a digit'] ~)
              :-  'title'
              (pairs:enjs:format ['type' s+'string'] ~)
              :-  'description'
              (pairs:enjs:format ['type' s+'string'] ~)
              :-  'privacy'
              (pairs:enjs:format ['type' s+'string'] ['description' s+'public, private, or secret. Default secret.'] ~)
          ==
          ['required' a+~[s+'name' s+'title']]
      ==
    ::
      :-  %'create-channel'
      :-  scope-create:g
      :-  'Create a chat channel in a group this ship admins, and open it to MCP clients. The nest is chat/~this-ship/name. Access is write unless the group ceiling is read. A hidden group is opened at write and its existing channels stay hidden.'
      %-  pairs:enjs:format
      :~  ['type' s+'object']
          :-  'properties'
          %-  pairs:enjs:format
          :~  :-  'group'
              (pairs:enjs:format ['type' s+'string'] ['description' s+'~ship/name'] ~)
              :-  'name'
              (pairs:enjs:format ['type' s+'string'] ['description' s+'term. The nest ship is this ship, not the group host.'] ~)
              :-  'title'
              (pairs:enjs:format ['type' s+'string'] ~)
              :-  'description'
              (pairs:enjs:format ['type' s+'string'] ~)
          ==
          ['required' a+~[s+'group' s+'name' s+'title']]
      ==
  ==
::
++  visible
  |=  scopes=(list @t)
  %+  murn  tool-desc
  |=  [name=@t scope=@t desc=@t schema=json]
  ?.  (holds scopes scope)  ~
  :-  ~
  %-  pairs:enjs:format
  :~  ['name' s+name]
      ['description' s+desc]
      ['inputSchema' schema]
  ==
::
++  arg
  |=  [jon=json key=@t]
  ^-  (unit json)
  =/  params  (ogot:g jon 'params')
  ?~  params  ~
  =/  arguments  (ogot:g u.params 'arguments')
  ?~  arguments  ~
  (ogot:g u.arguments key)
::
++  nest-of
  |=  jon=json
  (as-cord:g (arg jon 'nest'))
::
++  access-of
  |=  nest=@t
  ^-  (unit grant:g)
  =/  gs  groups-now
  ?~  gs  ~
  =/  got  (rows:g u.gs policy)
  |-
  ?~  got  ~
  ?:  =(nest.i.got nest)  `access.i.got
  $(got t.got)
::
++  pack
  |=  [cards=(list card) jon=json]
  ^-  [p=(list card) q=json r=_policy]
  [cards jon policy]
::
++  tool-err
  |=  [id=@ta msg=@t]
  ^-  [p=(list card) q=json r=_policy]
  [~ (rpc-err id ~.-32602 msg) policy]
::
++  call-tool
  |=  [scopes=(list @t) jon=json]
  ^-  [p=(list card) q=json r=_policy]
  =/  id=@ta
    =/  raw  (ogot:g jon 'id')
    ?~  raw  '0'
    ?.  ?=([%n *] u.raw)  '0'
    p.u.raw
  =/  name
    =/  params  (ogot:g jon 'params')
    ?~  params  ~
    (str-at:g u.params 'name')
  ?~  name  (pack ~ (rpc-err id ~.-32602 'missing tool name'))
  ?+  u.name  (pack ~ (rpc-err id ~.-32602 'unknown tool'))
      %'list-channels'
    ?.  (holds scopes scope-list:g)
      (pack ~ (rpc-err id ~.-32602 'missing scope groups-mcp.channels.list'))
    =/  gs  (fall groups-now *json)
    =/  got  (rows:g gs policy)
    =/  text
      %-  en:json:html
      :-  %a
      %+  turn  got
      |=  r=channel-row:g
      %-  pairs:enjs:format
      :~  ['nest' s+nest.r]
          ['group' s+group.r]
          ['title' s+title.r]
          ['kind' s+kind.r]
          ['access' s+access.r]
      ==
    (pack ~ (tool-result id text))
  ::
      %'read-posts'
    ?.  (holds scopes scope-read:g)
      (pack ~ (rpc-err id ~.-32602 'missing scope groups-mcp.channels.read'))
    =/  nest  (nest-of jon)
    ?~  nest  (pack ~ (rpc-err id ~.-32602 'nest is required'))
    =/  acc  (access-of u.nest)
    ?.  (allows:g %read acc)
      (pack ~ (rpc-err id ~.-32602 'channel is not readable'))
    ?.  =((kind-of:g u.nest) 'chat')
      (pack ~ (rpc-err id ~.-32602 'only chat channels can be read'))
    =/  parts  (parse-nest u.nest)
    ?~  parts  (pack ~ (rpc-err id ~.-32602 'nest must be kind/~ship/name'))
    =/  n  (clamp-count jon)
    =/  [kind=@tas ship=@p name=@tas]  u.parts
    =/  pax=path
      /v1/[kind]/(scot %p ship)/[name]/posts/newest/(scot %ud n)/post/json
    =/  page  (gx-json %channels pax)
    ?~  page  (pack ~ (rpc-err id ~.-32603 'channels scry failed'))
    =/  posts  (ogot:g u.page 'posts')
    ?~  posts  (pack ~ (tool-result id '[]'))
    =/  text
      %-  en:json:html
      :-  %a
      ?.  ?=([%o *] u.posts)  ~
      %+  turn
        %+  sort  ~(tap by p.u.posts)
        |=  [[a=@t *] [b=@t *]]
        (gth (fall (slaw %ud b) 0) (fall (slaw %ud a) 0))
      |=  [pid=@t post=json]
      %-  pairs:enjs:format
      :~  ['id' s+(post-id pid post)]
          ['text' s+(post-text post)]
      ==
    (pack ~ (tool-result id text))
  ::
      %'add-post'
    ?.  (holds scopes scope-write:g)
      (pack ~ (rpc-err id ~.-32602 'missing scope groups-mcp.channels.write'))
    =/  nest  (nest-of jon)
    ?~  nest  (pack ~ (rpc-err id ~.-32602 'nest is required'))
    =/  acc  (access-of u.nest)
    ?.  (allows:g %write acc)
      (pack ~ (rpc-err id ~.-32602 'channel is not writable'))
    ?.  =((kind-of:g u.nest) 'chat')
      (pack ~ (rpc-err id ~.-32602 'only chat channels can be written'))
    =/  txt  (as-cord:g (arg jon 'text'))
    ?~  txt  (pack ~ (rpc-err id ~.-32602 'text is required'))
    =/  parsed  (parse-nest u.nest)
    ?~  parsed  (pack ~ (rpc-err id ~.-32602 'nest must be kind/~ship/name'))
    ::  The parsed kind is a @tas. %channels clams the vase, and a
    ::  general term does not nest into kind=?(%chat %diary %heap).
    =/  [kind=@tas ship=@p name=@tas]  u.parsed
    ?.  =(kind %chat)
      (pack ~ (rpc-err id ~.-32602 'only chat channels can be written'))
    =/  memo  [~[[%inline ~[u.txt]]] our.bowl now.bowl]
    =/  essay  [memo /chat ~ ~]
    =/  act  [%channel [%chat ship name] [%post [%add essay]]]
    =/  poke=card
      :*  %pass  /post
          %agent  [our.bowl %channels]
          %poke  %channel-action-2
          !>(act)
      ==
    (pack ~[poke] (tool-result id 'submitted'))
  ::
      %'create-group'
    ?.  (holds scopes scope-create:g)
      (tool-err id 'missing scope groups-mcp.create')
    =/  name-c  (as-cord:g (arg jon 'name'))
    ?~  name-c  (tool-err id 'name is required')
    =/  name  (parse-term:g u.name-c)
    ?~  name
      (tool-err id 'name must be a term: lowercase letters, digits, and hyphens, not starting with a digit')
    =/  title  (as-cord:g (arg jon 'title'))
    ?~  title  (tool-err id 'title is required')
    ?:  =('' u.title)  (tool-err id 'title is required')
    =/  desc  (fall (as-cord:g (arg jon 'description')) '')
    =/  praw  (as-cord:g (arg jon 'privacy'))
    =/  priv=(unit ?(%public %private %secret))
      ?~  praw  `%secret
      (parse-priv:g u.praw)
    ?~  priv  (tool-err id 'privacy must be public, private, or secret')
    =/  gs  groups-now
    ?~  gs  (tool-err id 'groups scry failed')
    ?.  ?=([%o *] u.gs)  (tool-err id 'groups scry failed')
    =/  flag  (flag-cord:g our.bowl u.name)
    ?^  (group-of:g u.gs flag)  (tool-err id 'group already exists')
    =/  next  (open-group:g policy flag)
    =/  built
      ?-  u.priv
        %public   [(group-command:g u.name u.title desc %public) 'public']
        %private  [(group-command:g u.name u.title desc %private) 'private']
        %secret   [(group-command:g u.name u.title desc %secret) 'secret']
      ==
    =/  act  -.built
    =/  priv-c=@t  +.built
    =/  poke=card
      :*  %pass  /create/group
          %agent  [our.bowl %groups]
          %poke  %group-command
          !>(act)
      ==
    =/  text
      %-  en:json:html
      %-  pairs:enjs:format
      :~  ['flag' s+flag]
          ['title' s+u.title]
          ['privacy' s+priv-c]
          ['access' s+'write']
      ==
    [~[poke] (tool-result id text) next]
  ::
      %'create-channel'
    ?.  (holds scopes scope-create:g)
      (tool-err id 'missing scope groups-mcp.create')
    =/  name-c  (as-cord:g (arg jon 'name'))
    ?~  name-c  (tool-err id 'name is required')
    =/  name  (parse-term:g u.name-c)
    ?~  name
      (tool-err id 'name must be a term: lowercase letters, digits, and hyphens, not starting with a digit')
    =/  title  (as-cord:g (arg jon 'title'))
    ?~  title  (tool-err id 'title is required')
    ?:  =('' u.title)  (tool-err id 'title is required')
    =/  desc  (fall (as-cord:g (arg jon 'description')) '')
    =/  group-c  (as-cord:g (arg jon 'group'))
    ?~  group-c  (tool-err id 'group is required')
    =/  parsed  (parse-flag:g u.group-c)
    ?~  parsed  (tool-err id 'group must be ~ship/name')
    =/  gs  groups-now
    ?~  gs  (tool-err id 'groups scry failed')
    ?.  ?=([%o *] u.gs)  (tool-err id 'groups scry failed')
    =/  grp  (group-of:g u.gs u.group-c)
    ?~  grp  (tool-err id 'group was not found')
    =/  ourc  (scot %p our.bowl)
    ?.  (is-admin:g u.grp ourc)
      (tool-err id 'this ship is not an admin of that group')
    =/  writers  (writer-set:g (admin-sects:g u.grp ourc))
    ?:  =(0 ~(wyt in writers))
      (tool-err id 'this ship is not an admin of that group')
    =/  nest  (nest-cord:g our.bowl u.name)
    =/  existing  (nest-names:g u.grp)
    ?:  (lien existing |=(n=@t =(n nest)))
      (tool-err id 'channel already exists')
    =/  opened  (open-channel:g policy u.group-c nest existing)
    =/  [gship=@p gname=@tas]  u.parsed
    =/  act
      (channel-action:g u.name gship gname u.title desc writers)
    =/  poke=card
      :*  %pass  /create/channel
          %agent  [our.bowl %channels]
          %poke  %channel-action-2
          !>(act)
      ==
    =/  access-c=@t
      ?-  access.opened
        %read   'read'
        %write  'write'
      ==
    =/  text
      %-  en:json:html
      %-  pairs:enjs:format
      :~  ['nest' s+nest]
          ['group' s+u.group-c]
          ['title' s+u.title]
          ['access' s+access-c]
      ==
    [~[poke] (tool-result id text) pol.opened]
  ==
::
++  parse-nest
  |=  nest=@t
  ^-  (unit [@tas @p @tas])
  =/  run
    %-  mule
    |.  (scan (trip nest) ;~((glue fas) sym ;~(pfix sig fed:ag) sym))
  ?:(?=(%| -.run) ~ `p.run)
::
++  clamp-count
  |=  jon=json
  ^-  @ud
  =/  raw  (arg jon 'count')
  ?~  raw  20
  ?.  ?=([%n *] u.raw)  20
  =/  n  (fall (slaw %ud p.u.raw) 20)
  ?:  (lth n 1)  1
  ?:  (gth n 50)  50
  n
::
++  post-text
  |=  post=json
  ^-  @t
  =/  essay  (fall (ogot:g post 'essay') post)
  (text-of:g essay)
::
++  post-id
  |=  [pid=@t post=json]
  ^-  @t
  =/  seal  (ogot:g post 'seal')
  ?~  seal  pid
  (fall (str-at:g u.seal 'id') pid)
::
++  handle-http
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (quip card versioned-state)
  =/  site  (site-of url.request.req)
  ?:  ?=([%groups-mcp %manage *] site)
    (handle-manage eyre-id req)
  (handle-mcp eyre-id req)
::
++  handle-manage
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (quip card versioned-state)
  ?.  ?&  authenticated.req
          =(src.bowl our.bowl)
      ==
    [(html-pay eyre-id 401 "<p>Log in with the ship code.</p>") state]
  =/  groups  (fall groups-now *json)
  ?+  method.request.req
    [(html-pay eyre-id 405 "<p>Use GET or POST.</p>") state]
  ::
      %'GET'
    :_  state
    (html-pay eyre-id 200 (manage-page groups policy %none))
  ::
      %'POST'
    =/  body  ?~(body.request.req "" (trip q.u.body.request.req))
    =/  next  (apply-save body groups policy)
    =/  note=?(%none %saved %unchanged)
      ?.  ?=([%o *] groups)  %none
      ?:(=(next policy) %unchanged %saved)
    :_  state(policy next)
    (html-pay eyre-id 200 (manage-page groups next note))
  ==
::
++  site-of
  |=  url=@t
  ^-  (list @t)
  =/  full=tape  (trip url)
  =/  cut  (find "?" full)
  =/  head=tape  ?~(cut full (scag u.cut full))
  %+  murn  (split head '/')
  |=  s=tape
  ?~  s  ~
  `(crip s)
::
++  pair-list
  |=  body=tape
  ^-  (list [tape tape])
  %+  murn  (split body '&')
  |=  p=tape
  ?~  p  ~
  =/  bits  (split p '=')
  ?~  bits  ~
  ?~  t.bits  `[(decode i.bits) ""]
  `[(decode i.bits) (decode (zing (join "=" t.bits)))]
::
++  apply-save
  |=  [body=tape groups=json prev=(map @t group-policy:g)]
  ^-  (map @t group-policy:g)
  (apply-edits:g (edits-of (pair-list body)) groups prev)
::
::  Form names are ceil.<flag> and over.<flag>|<nest>.
::
++  edits-of
  |=  pairs=(list [tape tape])
  ^-  (list manage-edit:g)
  %+  murn  pairs
  |=  [key=tape val=tape]
  ^-  (unit manage-edit:g)
  =/  head=tape  (scag 5 key)
  ?:  =(head "ceil.")
    =/  flag-t=tape  (slag 5 key)
    ?~  flag-t  ~
    `[%ceil (crip flag-t) (parse-ceil val)]
  ?.  =(head "over.")  ~
  =/  bits  (split (slag 5 key) '|')
  ?~  bits  ~
  ?~  t.bits  ~
  ?.  ?=(~ t.t.bits)  ~
  ?~  i.bits  ~
  ?~  i.t.bits  ~
  `[%over (crip i.bits) (crip i.t.bits) (parse-over val)]
::
++  parse-ceil
  |=  t=tape
  ^-  ceil:g
  ?:  =(t "read")  %read
  ?:  =(t "write")  %write
  %hide
::
++  parse-over
  |=  t=tape
  ^-  over:g
  ?:  =(t "read")  %read
  ?:  =(t "write")  %write
  ?:  =(t "hide")  %hide
  %inherit
::
++  split
  |=  [t=tape sep=@]
  ^-  (list tape)
  =|  cur=tape
  =|  out=(list tape)
  |-
  ?~  t  (flop [(flop cur) out])
  ?:  =(i.t sep)
    $(t t.t, cur "", out [(flop cur) out])
  $(t t.t, cur [i.t cur])
::
++  decode
  |=  t=tape
  ^-  tape
  |-
  ?~  t  ~
  ?:  =(i.t '+')  [' ' $(t t.t)]
  ?.  =(i.t '%')  [i.t $(t t.t)]
  ?~  t.t  [i.t ~]
  ?~  t.t.t  [i.t t.t]
  =/  hex  (rush (rap 3 ~[i.t.t i.t.t.t]) hex:ag)
  ?~  hex  [i.t $(t t.t)]
  [u.hex $(t t.t.t.t)]
::
++  manage-page
  |=  [groups=json pol=(map @t group-policy:g) note=?(%none %saved %unchanged)]
  ^-  tape
  =/  inner=@t
    ?.  ?=([%o *] groups)
      '<p>Could not read the groups app.</p>'
    ?:  =(0 ~(wyt by p.groups))
      '<p>The groups app has no groups yet. Nothing to configure.</p>'
    (render-tree groups pol)
  %-  trip
  %+  rap  3
  :~
    '<!doctype html><meta charset="utf-8"><title>Groups MCP</title>'
    '<style>body{font:16px/1.45 system-ui,sans-serif;max-width:46rem;margin:2rem auto;padding:0 1rem;color:#1c1915}a{color:#1c4f8a}.meta{display:block;font-weight:400;color:#5c564c;font-size:.875rem}table{width:100%;border-collapse:collapse}th,td{padding:.45rem .25rem;vertical-align:top;text-align:left}th.name{font-weight:500}th.access,td.access{text-align:right;white-space:nowrap;width:1%}tr.channel th.name{padding-left:1.5rem}thead th{border-bottom:1px solid #efeae2}button,select{font:inherit}button{margin-top:1rem}</style>'
    '<h1>Groups MCP</h1>'
    '<p>Choose which channels clients may use. A channel cannot be more open than its group. Inherit uses that ceiling. Hidden groups are invisible to clients.</p>'
    '<p>A client with the create scope can add a group or a chat channel. New groups start at write. Hide a group or a channel here to take that access away.</p>'
    ?:(?=(%saved note) '<p>Saved.</p>' '')
    ?:(?=(%unchanged note) '<p>Policy unchanged.</p>' '')
    inner
  ==
::
++  render-tree
  |=  [groups=json pol=(map @t group-policy:g)]
  ^-  @t
  ?>  ?=([%o *] groups)
  %+  rap  3
  :~
    '<form method="post" action="/groups-mcp/manage"><table>'
    '<thead><tr><th scope="col">Name</th><th scope="col" class="access">Access</th></tr></thead><tbody>'
    %+  rap  3
    %+  turn  ~(tap by p.groups)
    |=  [flag=@t grp=json]
    ^-  @t
    (render-group flag grp pol)
    '</tbody></table><button type="submit">Save</button></form>'
  ==
::
++  render-group
  |=  [flag=@t grp=json pol=(map @t group-policy:g)]
  ^-  @t
  =/  got  (~(get by pol) flag)
  =/  ceiling=ceil:g  ?~(got %hide ceiling.u.got)
  =/  chans=(map @t over:g)  ?~(got ~ channels.u.got)
  =/  title  (title-of:g grp flag)
  %+  rap  3
  :~
    '<tr><th scope="row" class="name">'
    (esc title)
    '<span class="meta">'
    (esc flag)
    '</span></th><td class="access"><select name="'
    (esc (rap 3 'ceil.' flag ~))
    '" aria-label="Group ceiling '
    (esc title)
    '">'
    (opt 'hide' 'Hidden' =(ceiling %hide))
    (opt 'read' 'Read' =(ceiling %read))
    (opt 'write' 'Write' =(ceiling %write))
    '</select></td></tr>'
    %+  rap  3
    %+  turn  (chan-list grp)
    |=  [nest=@t c=json]
    ^-  @t
    (render-channel flag ceiling chans nest c)
  ==
::
++  render-channel
  |=  [flag=@t ceiling=ceil:g chans=(map @t over:g) nest=@t c=json]
  ^-  @t
  =/  title  (title-of:g c nest)
  =/  head=@t
    %+  rap  3
    :~
      '<tr class="channel"><th scope="row" class="name">'
      (esc title)
      '<span class="meta">'
      (esc nest)
      '</span></th><td class="access">'
    ==
  ?.  =((kind-of:g nest) 'chat')
    (rap 3 head 'Chat only</td></tr>' ~)
  =/  mode=over:g  (fall (~(get by chans) nest) %inherit)
  %+  rap  3
  :~
    head
    '<select name="'
    (esc (rap 3 'over.' flag '|' nest ~))
    '" aria-label="Channel access '
    (esc title)
    '">'
    (opt 'inherit' 'Inherit' =(mode %inherit))
    (opt 'hide' 'Hidden' =(mode %hide))
    (opt 'read' 'Read' =(mode %read))
    (opt 'write' 'Write' =(mode %write))
    '</select>'
    (channel-hint ceiling mode)
    '</td></tr>'
  ==
::
++  channel-hint
  |=  [ceiling=ceil:g mode=over:g]
  ^-  @t
  =/  eff  (effective:g ceiling mode)
  ?:  =(mode %inherit)
    (rap 3 '<span class="meta">inherits ' (grant-name eff) '</span>' ~)
  ?:  ?|  =(mode %hide)
          =(eff ?:(=(mode %write) `%write `%read))
      ==
    ''
  (rap 3 '<span class="meta">clamped to ' (grant-name eff) '</span>' ~)
::
++  chan-list
  |=  grp=json
  ^-  (list [nest=@t c=json])
  =/  ch  (ogot:g grp 'channels')
  ?~  ch  ~
  ?.  ?=([%o *] u.ch)  ~
  ~(tap by p.u.ch)
::
++  ceil-name
  |=  c=ceil:g
  ^-  @t
  ?-  c
    %hide   'Hidden'
    %read   'Read'
    %write  'Write'
  ==
::
++  grant-name
  |=  a=(unit grant:g)
  ^-  @t
  ?~  a  'Hidden'
  ?-  u.a
    %read   'Read'
    %write  'Write'
  ==
::
++  esc
  |=  raw=@t
  ^-  @t
  %+  rap  3
  %+  turn  (trip raw)
  |=  c=@tD
  ^-  @t
  ?:  =(c '&')  '&amp;'
  ?:  =(c '<')  '&lt;'
  ?:  =(c '>')  '&gt;'
  ?:  =(c '"')  '&quot;'
  (crip ~[c])
::
++  opt
  |=  [val=@t label=@t on=?]
  ^-  @t
  %+  rap  3
  :~
    '<option value="'
    val
    '"'
    ?:(on ' selected' '')
    '>'
    label
    '</option>'
  ==
::
++  handle-mcp
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (quip card versioned-state)
  =/  who  (admit req)
  ?:  ?=(%down -.who)
    [(json-pay eyre-id 503 (pairs:enjs:format ['error' s+'wicket_down']~) ~) state]
  ?:  ?=(%no -.who)
    =/  org  (fall origin-now '')
    =/  meta  (metadata:wicket-check org (audience org))
    =/  hdr=@t
      (rap 3 'Bearer realm="wicket", resource_metadata="' meta '"' ~)
    :_  state
    (json-pay eyre-id 401 (pairs:enjs:format ['error' s+'invalid_token']~) ['www-authenticate' hdr]~)
  ?>  ?=(%yes -.who)
  ?.  =(method.request.req %'POST')
    [(json-pay eyre-id 405 (pairs:enjs:format ['error' s+'use post']~) ~) state]
  =/  parsed
    ?~  body.request.req  ~
    (de:json:html q.u.body.request.req)
  ?~  parsed
    [(json-pay eyre-id 400 (pairs:enjs:format ['error' s+'bad json']~) ~) state]
  =/  method  (str-at:g u.parsed 'method')
  =/  id=@ta
    =/  raw  (ogot:g u.parsed 'id')
    ?~  raw  '0'
    ?.  ?=([%n *] u.raw)  '0'
    p.u.raw
  ?~  method
    [(json-pay eyre-id 200 (rpc-err id ~.-32600 'missing method') ~[['MCP-Protocol-Version' mcp-version]]) state]
  ?+  u.method
    [(json-pay eyre-id 200 (rpc-err id ~.-32601 'method not found') ~[['MCP-Protocol-Version' mcp-version]]) state]
  ::
      %'initialize'
    =/  jon
      %-  pairs:enjs:format
      :~  ['id' n+id]
          ['jsonrpc' s+'2.0']
          :-  'result'
          %-  pairs:enjs:format
          :~  ['protocolVersion' s+mcp-version]
              :-  'capabilities'
              (pairs:enjs:format ['tools' (pairs:enjs:format ['listChanged' b+%.n] ~)] ~)
              :-  'serverInfo'
              (pairs:enjs:format ['name' s+'groups-mcp'] ['version' s+'0.1.0'] ~)
          ==
      ==
    [(json-pay eyre-id 200 jon ~[['MCP-Protocol-Version' mcp-version]]) state]
  ::
      %'notifications/initialized'
    [(json-pay eyre-id 202 [%o ~] ~[['MCP-Protocol-Version' mcp-version]]) state]
  ::
      %'tools/list'
    =/  jon
      %-  pairs:enjs:format
      :~  ['id' n+id]
          ['jsonrpc' s+'2.0']
          ['result' (pairs:enjs:format ['tools' a+(visible scopes.who)] ~)]
      ==
    [(json-pay eyre-id 200 jon ~[['MCP-Protocol-Version' mcp-version]]) state]
  ::
      %'tools/call'
    =/  called  (call-tool scopes.who u.parsed)
    :_  state(policy r.called)
    (weld p.called (json-pay eyre-id 200 q.called ~[['MCP-Protocol-Version' mcp-version]]))
  ==
--
--
