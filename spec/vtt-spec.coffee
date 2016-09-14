describe 'WebVTT grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-vtt')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.vtt')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.vtt'

  describe 'timestamp', ->
    it 'allow ignore the hours', ->
      tokens = grammar.tokenizeLines '''(?x)
        WEBVTT

        00:00.000 --> 00:10.000
      '''
      expect(tokens[3][0]).toEqual value: '00', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.minute.vtt']
      expect(tokens[3][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'punctuation.separator.colon.vtt']
      expect(tokens[3][2]).toEqual value: '00.000', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.second.vtt']

    it 'allow the hours have two or more digits', ->
      tokens = grammar.tokenizeLines '''(?x)
        WEBVTT

        100:00:00.000 --> 100:00:10.000
      '''
      expect(tokens[3][0]).toEqual value: '100', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.hour.vtt']
      expect(tokens[3][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'punctuation.separator.colon.vtt']
      expect(tokens[3][2]).toEqual value: '00', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.minute.vtt']
      expect(tokens[3][3]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'punctuation.separator.colon.vtt']
      expect(tokens[3][4]).toEqual value: '00.000', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.second.vtt']

  describe 'percentage', ->
    it 'allow float', ->
      tokens = grammar.tokenizeLines '''(?x)
        WEBVTT

        00:00:00.000 --> 00:00:10.000 line:42.000%
      '''
      expect(tokens[3][16]).toEqual value: '42.000%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']

  describe 'file body', ->
    it 'start with WEBVTT', ->
      tokens = grammar.tokenizeLines '''(?x)
        WEBVTT
      '''
      expect(tokens[1][0]).toEqual value: 'WEBVTT', scopes: ['source.vtt', 'meta.file-body.vtt', 'entity.name.section.webvtt.vtt']

    it 'parses strings after WEBVTT as comment', ->
      tokens = grammar.tokenizeLines '''(?x)
        WEBVTT comment
      '''
      expect(tokens[1][0]).toEqual value: 'WEBVTT', scopes: ['source.vtt', 'meta.file-body.vtt', 'entity.name.section.webvtt.vtt']
      expect(tokens[1][1]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt']
      expect(tokens[1][2]).toEqual value: 'comment', scopes: ['source.vtt', 'meta.file-body.vtt', 'comment.line.character.vtt']

    describe 'region definition block', ->
      it 'start with REGION', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
        '''
        expect(tokens[3][0]).toEqual value: 'REGION', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'entity.name.section.region.vtt']

      it 'parses region identifier setting', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
          id:fred
        '''
        expect(tokens[4][0]).toEqual value: 'id', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-identifier-setting.vtt', 'support.type.region-identifier-setting.vtt']
        expect(tokens[4][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-identifier-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][2]).toEqual value: 'fred', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-identifier-setting.vtt', 'string.unquoted.region-identifier-setting.vtt']

      it 'parses region width setting', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
          width:40%
        '''
        expect(tokens[4][0]).toEqual value: 'width', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-width-setting.vtt', 'support.type.region-width-setting.vtt']
        expect(tokens[4][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-width-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][2]).toEqual value: '40%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-width-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']

      it 'parses region lines setting', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
          lines:3
        '''
        expect(tokens[4][0]).toEqual value: 'lines', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-lines-setting.vtt', 'support.type.region-lines-setting.vtt']
        expect(tokens[4][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-lines-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][2]).toEqual value: '3', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-lines-setting.vtt', 'constant.numeric.region-lines-setting.vtt']

      it 'parses region anchor setting', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
          regionanchor:0%,100%
        '''
        expect(tokens[4][0]).toEqual value: 'regionanchor', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-anchor-setting.vtt', 'support.type.region-anchor-setting.vtt']
        expect(tokens[4][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-anchor-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][2]).toEqual value: '0%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-anchor-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']
        expect(tokens[4][3]).toEqual value: ',', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-anchor-setting.vtt', 'punctuation.separator.comma.vtt']
        expect(tokens[4][4]).toEqual value: '100%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-anchor-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']

      it 'parses region viewport anchor setting', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
          viewportanchor:0%,100%
        '''
        expect(tokens[4][0]).toEqual value: 'viewportanchor', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-viewport-anchor-setting.vtt', 'support.type.region-viewport-anchor-setting.vtt']
        expect(tokens[4][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-viewport-anchor-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][2]).toEqual value: '0%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-viewport-anchor-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']
        expect(tokens[4][3]).toEqual value: ',', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-viewport-anchor-setting.vtt', 'punctuation.separator.comma.vtt']
        expect(tokens[4][4]).toEqual value: '100%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-viewport-anchor-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']

      it 'parses region scroll setting', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
          scroll:up
        '''
        expect(tokens[4][0]).toEqual value: 'scroll', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-scroll-setting.vtt', 'support.type.region-scroll-setting.vtt']
        expect(tokens[4][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-scroll-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][2]).toEqual value: 'up', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-scroll-setting.vtt', 'support.constant.region-scroll-setting.vtt']

      it 'parses multi region settings', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          REGION
          id:fred width:40%
          lines:3
          scroll:up
        '''
        expect(tokens[4][0]).toEqual value: 'id', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-identifier-setting.vtt', 'support.type.region-identifier-setting.vtt']
        expect(tokens[4][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-identifier-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][2]).toEqual value: 'fred', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-identifier-setting.vtt', 'string.unquoted.region-identifier-setting.vtt']
        expect(tokens[4][3]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt']
        expect(tokens[4][4]).toEqual value: 'width', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-width-setting.vtt', 'support.type.region-width-setting.vtt']
        expect(tokens[4][5]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-width-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[4][6]).toEqual value: '40%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-width-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']
        expect(tokens[5][0]).toEqual value: 'lines', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-lines-setting.vtt', 'support.type.region-lines-setting.vtt']
        expect(tokens[5][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-lines-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[5][2]).toEqual value: '3', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-lines-setting.vtt', 'constant.numeric.region-lines-setting.vtt']
        expect(tokens[6][0]).toEqual value: 'scroll', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-scroll-setting.vtt', 'support.type.region-scroll-setting.vtt']
        expect(tokens[6][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-scroll-setting.vtt', 'punctuation.definition.colon.vtt']
        expect(tokens[6][2]).toEqual value: 'up', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.region-definition-block.vtt', 'meta.region-scroll-setting.vtt', 'support.constant.region-scroll-setting.vtt']

    describe 'style block', ->
      it 'start with STYLE', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          STYLE
        '''
        expect(tokens[3][0]).toEqual value: 'STYLE', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.style-block.vtt', 'entity.name.section.style.vtt']

      # TODO
      it 'parses lines after STYLE as CSS stylesheet'

    describe 'comment block', ->
      it 'start with NOTE', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          NOTE
        '''
        expect(tokens[3][0]).toEqual value: 'NOTE', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.comment-block.vtt', 'entity.name.section.comment.vtt']

      it 'parses comments', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          NOTE  comment
          comment
        '''
        expect(tokens[3][0]).toEqual value: 'NOTE', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.comment-block.vtt', 'entity.name.section.comment.vtt']
        expect(tokens[3][1]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.comment-block.vtt']
        expect(tokens[3][2]).toEqual value: ' comment', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.comment-block.vtt', 'comment.line.character.vtt']
        expect(tokens[4][0]).toEqual value: 'comment', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.comment-block.vtt', 'comment.line.character.vtt']

    describe 'cue block', ->
      it 'parses cue identifier', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          cue-identifier
        '''
        expect(tokens[3][0]).toEqual value: 'cue-identifier', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-identifier.vtt', 'variable.other.cue-identifier.vtt']

      it 'parses cue timings', ->
        tokens = grammar.tokenizeLines '''(?x)
          WEBVTT

          00:00:00.000 --> 00:00:10.000
        '''
        expect(tokens[3][0]).toEqual value: '00', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.hour.vtt']
        expect(tokens[3][1]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'punctuation.separator.colon.vtt']
        expect(tokens[3][2]).toEqual value: '00', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.minute.vtt']
        expect(tokens[3][3]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'punctuation.separator.colon.vtt']
        expect(tokens[3][4]).toEqual value: '00.000', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.second.vtt']
        expect(tokens[3][5]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt']
        expect(tokens[3][6]).toEqual value: '-->', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'punctuation.separator.vtt']
        expect(tokens[3][7]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt']
        expect(tokens[3][8]).toEqual value: '00', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.hour.vtt']
        expect(tokens[3][9]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'punctuation.separator.colon.vtt']
        expect(tokens[3][10]).toEqual value: '00', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.minute.vtt']
        expect(tokens[3][11]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'punctuation.separator.colon.vtt']
        expect(tokens[3][12]).toEqual value: '10.000', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.cue-timings.vtt', 'meta.timestamp.vtt', 'constant.numeric.time.second.vtt']

      describe 'parses cue settings list', ->
        it 'parses vertical text cue setting', ->
          tokens = grammar.tokenizeLines '''(?x)
            WEBVTT

            00:00:00.000 --> 00:00:10.000 vertical:rl
          '''
          expect(tokens[3][13]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt']
          expect(tokens[3][14]).toEqual value: 'vertical', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.vertical-text-cue-setting.vtt', 'support.type.vertical-text-cue-setting.vtt']
          expect(tokens[3][15]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.vertical-text-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][16]).toEqual value: 'rl', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.vertical-text-cue-setting.vtt', 'support.constant.vertical-text-cue-setting.vtt']

        it 'parses line cue setting', ->
          tokens = grammar.tokenizeLines '''(?x)
            WEBVTT

            00:00:00.000 --> 00:00:10.000 line:42% line:-42 line:42,start
          '''
          expect(tokens[3][13]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt']
          expect(tokens[3][14]).toEqual value: 'line', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'support.type.line-cue-setting.vtt']
          expect(tokens[3][15]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][16]).toEqual value: '42%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']
          expect(tokens[3][17]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt']
          expect(tokens[3][18]).toEqual value: 'line', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'support.type.line-cue-setting.vtt']
          expect(tokens[3][19]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][20]).toEqual value: '-42', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'constant.numeric.line-cue-setting.vtt']
          expect(tokens[3][21]).toEqual value: ' ', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt']
          expect(tokens[3][22]).toEqual value: 'line', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'support.type.line-cue-setting.vtt']
          expect(tokens[3][23]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][24]).toEqual value: '42', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'constant.numeric.line-cue-setting.vtt']
          expect(tokens[3][25]).toEqual value: ',', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'punctuation.separator.comma.vtt']
          expect(tokens[3][26]).toEqual value: 'start', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.line-cue-setting.vtt', 'support.constant.line-cue-setting.vtt']

        it 'parses position cue setting', ->
          tokens = grammar.tokenizeLines '''(?x)
            WEBVTT

            00:00:00.000 --> 00:00:10.000 position:42%,line-left
          '''
          expect(tokens[3][14]).toEqual value: 'position', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.position-cue-setting.vtt', 'support.type.position-cue-setting.vtt']
          expect(tokens[3][15]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.position-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][16]).toEqual value: '42%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.position-cue-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']
          expect(tokens[3][17]).toEqual value: ',', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.position-cue-setting.vtt', 'punctuation.separator.comma.vtt']
          expect(tokens[3][18]).toEqual value: 'line-left', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.position-cue-setting.vtt', 'support.constant.position-cue-setting.vtt']

        it 'parses size cue setting', ->
          tokens = grammar.tokenizeLines '''(?x)
            WEBVTT

            00:00:00.000 --> 00:00:10.000 size:42%
          '''
          expect(tokens[3][14]).toEqual value: 'size', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.size-cue-setting.vtt', 'support.type.size-cue-setting.vtt']
          expect(tokens[3][15]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.size-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][16]).toEqual value: '42%', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.size-cue-setting.vtt', 'meta.percentage.vtt', 'constant.numeric.percentage.vtt']

        it 'parses alignment cue setting', ->
          tokens = grammar.tokenizeLines '''(?x)
            WEBVTT

            00:00:00.000 --> 00:00:10.000 align:center
          '''
          expect(tokens[3][14]).toEqual value: 'align', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.alignment-cue-setting.vtt', 'support.type.alignment-cue-setting.vtt']
          expect(tokens[3][15]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.alignment-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][16]).toEqual value: 'center', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.alignment-cue-setting.vtt', 'support.constant.alignment-cue-setting.vtt']

        it 'parses region cue setting', ->
          tokens = grammar.tokenizeLines '''(?x)
            WEBVTT

            00:00:00.000 --> 00:00:10.000 region:fred
          '''
          expect(tokens[3][14]).toEqual value: 'region', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.region-cue-setting.vtt', 'support.type.region-cue-setting.vtt']
          expect(tokens[3][15]).toEqual value: ':', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.region-cue-setting.vtt', 'punctuation.definition.colon.vtt']
          expect(tokens[3][16]).toEqual value: 'fred', scopes: ['source.vtt', 'meta.file-body.vtt', 'meta.cue-block.vtt', 'meta.region-cue-setting.vtt', 'string.unquoted.region-cue-setting.vtt']

      # TODO
      it 'parses cue text'
