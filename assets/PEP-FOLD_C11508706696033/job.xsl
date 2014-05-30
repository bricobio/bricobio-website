<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml">
  
  <xsl:output method="html" indent="yes" />	

  <xsl:include href="remove_ns.xsl" />

  <xsl:param name="jobPID" ></xsl:param>  

  <xsl:param name="servicePID" ></xsl:param>  

  <xsl:param name="isIE" >False</xsl:param>  

  <xsl:param name="previewDataLimit" >99999999999999999999999999</xsl:param>  
  
  <xsl:variable name="job" select="/"/>
  
  <xsl:variable name="jobId" select="$job/jobState/id"/>

  <xsl:variable name="statusValue">
    <xsl:choose>
      <xsl:when test="/jobState">
        <xsl:choose>
          <xsl:when test="/jobState/status">
            <xsl:value-of select="/jobState/status/value/text()" />
          </xsl:when>      
          <xsl:otherwise>
            <xsl:value-of select="document(concat($job/jobState/id,'/mobyle_status.xml'))/status/value/text()" />        
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="statusMessage">
    <xsl:choose>
      <xsl:when test="/jobState">
        <xsl:choose>
          <xsl:when test="/jobState/status">
            <xsl:value-of select="/jobState/status/message/text()" />
          </xsl:when>      
          <xsl:otherwise>
            <xsl:value-of select="document(concat($job/jobState/id,'/mobyle_status.xml'))/status/message/text()" />        
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>  

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$jobPID!=''">
        <xsl:apply-templates select="/jobState/program|/jobState/workflow" />              
      </xsl:when>
      <xsl:otherwise>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
          <!-- TODO update all CSS links -->
          <head>
          <!-- here we compute the path to the css stylesheets dir, based on the href pseudo-attribute of the XSL processing instruction -->
          <xsl:variable name="xslUri" select="translate(substring-before(substring-after(processing-instruction('xml-stylesheet'), 'href='), ' '),'&quot;','')" />
          <xsl:variable name="cssBase" select="concat(substring-before($xslUri, '/xsl'),'/css/')" />
          <title>Mobyle job report for <xsl:value-of select="$jobId"/></title>
          <style type="text/css">
            @import "<xsl:value-of select='$cssBase' />mobyle.css"; 
            @import "mobyle.css"; 
            .minimizable.minimized  > legend{
                background-image: none;
                display:inherit;
            }

            .minimizable.minimized > *{
                display:block;
            }
          </style>
          </head>
          <body>
            <xsl:apply-templates select="/jobState/program|/jobState/workflow" />              
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>    
    

  <xsl:template match="/jobState/program|/jobState/workflow">    
    <div class="job"
      data-jobid="{$jobId}"
      data-jobpid="{$jobPID}"
      data-pid="{$jobPID}"
      data-servicepid="{$servicePID}"
      data-servicename="{$job/jobState/name/text()}" 
      data-servicelocalname="{/jobState/*/head/name/text()}" 
      data-jobdate="{$job/jobState/date/text()}" 
      data-jobstatus="{$statusValue}"
      data-jobmessage="{$statusMessage}">
        <fieldset class="job_controls">
          <legend class="jobstatus {$statusValue}" title="status: {$statusValue}">
            <xsl:value-of select="$jobId" />
          </legend>
          <xsl:if test="$statusMessage!=''">
            <div class="info" style="white-space:pre-wrap;">
              <xsl:value-of select="$statusMessage" />
            </div>            
          </xsl:if>
          <xsl:if test="$jobPID!=''"><!-- only display if jobPID available, i.e., we are working within the portal -->
            <xsl:if test="not($job/jobState/workflowID)">
              <xsl:if test="$statusValue!='finished' and $statusValue!='error' and $statusValue!='killed'">
                <a href="#" class="refresh_link"><button type="button">update</button></a>          
              </xsl:if>
              <a href="#user::help::{$jobId}" class="modalLink"><button type="button">get help</button></a>               
              <a href="#forms::{$servicePID}" class="link"><button type="button">back to form</button></a>                
              <a href="#user::jobremove::{$jobPID}" class="modalLink"><button type="button">remove job</button></a>                
            </xsl:if>
            <xsl:if test="$statusValue='finished' or $statusValue='error' or $statusValue='killed'">
              <a href="{$jobId}/{/jobState/*/head/name/text()}_{substring-after($jobId,concat(/jobState/*/head/name/text(),'/'))}.zip">
                <button type="button">download</button>
              </a>
            </xsl:if>
          </xsl:if>
          <xsl:if test="/jobState/program/head/progressReport">
            <fieldset class="minimizable">
              <legend>
                <xsl:choose>
                  <xsl:when test="/jobState/program/head/progressReport/@prompt">
                    <xsl:value-of select="/jobState/program/head/progressReport/@prompt"/>
                  </xsl:when>
                  <xsl:otherwise>
                    job progress report
                  </xsl:otherwise>
                </xsl:choose>
              </legend>
              <textarea class="progressReport" readonly="readonly" data-url="{$job/jobState/id}/{/jobState/program/head/progressReport/text()}" />
            </fieldset>
          </xsl:if>
        </fieldset>
      <xsl:if test="$job/jobState/data/output">
        <fieldset class="job_results">
          <legend>results</legend>
          <xsl:apply-templates select="/jobState/*/head/interface[@type='job_output']/*"/> 
        </fieldset>
      </xsl:if>
      <fieldset class="job_inputs">
        <legend>parameters</legend>
        <xsl:apply-templates select="/jobState/*/head/interface[@type='job_input']/*"/>
      </fieldset>
      <xsl:if test="$job/jobState/commandLine or $job/jobState/paramFiles/file">
        <fieldset class="job_details minimizable minimized">
          <legend>job execution</legend>
          <div>
          <xsl:apply-templates select="$job/jobState/commandLine"/>          
          <xsl:apply-templates select="$job/jobState/paramFiles/file"/>
          </div>
        </fieldset>
      </xsl:if>
      <xsl:if test="$job/jobState/jobLink">
        <xsl:apply-templates select="/jobState/workflow/flow"/>     
      </xsl:if>   
    </div>
  </xsl:template>

  <xsl:template match="flow">
    <xsl:if test="$jobPID!=''">
      <xsl:text disable-output-escaping="yes">&lt;![if !IE]&gt;</xsl:text>
        <fieldset class="job_details minimizable">
          <legend>workflow details</legend>
          <div>
            <center>
              <object class="workflow_graph" data="workflow_job_layout.py?id={$jobPID}">
                <iframe width="100%" class="workflow_graph" src="workflow_job_layout.py?id={$jobPID}" />
              </object>
            </center>
          </div>
        </fieldset>
      <xsl:text disable-output-escaping="yes">&lt;![endif]&gt;</xsl:text>              
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[@data-paragraphname]">
    <!-- do not display a paragraph unless there are data to be displayed -->
    <xsl:if test="$job/jobState/data//*[name/text()=current()//@data-parametername]">
      <xsl:element name="{local-name(.)}">
        <xsl:apply-templates select="@*|node()" />
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[@data-parametername]">
    <!-- do not display a parameter unless there are data to be displayed -->
    <xsl:variable name='parametername' select="@data-parametername"/>
    <xsl:if test="$job/jobState/data/*[parameter/name=$parametername]">
      <xsl:element name="{local-name(.)}" use-attribute-sets="param">
        <!-- override data-format for dynamically-specified version -->
        <xsl:attribute name="data-inputmodes">result</xsl:attribute>
        <xsl:attribute name="data-format">
          <xsl:apply-templates select="//parameter[name/text()=$parametername]/type/dataFormat" mode="dataFormats" />
        </xsl:attribute> 
        <xsl:attribute name="title">
          <xsl:value-of select="concat(//parameter[name/text()=$parametername]/type/biotype/text(), ' ',//parameter[name/text()=$parametername]/type/datatype/class)"/>
        </xsl:attribute>
        <xsl:apply-templates select="@*" />
	<span class="prompt"><xsl:value-of select="//parameter[name/text()=$parametername]/prompt/text()" /></span>
        <xsl:apply-templates select="xhtml:*" mode="pre"/>
        <!-- this part handles the display of results or parameter data which have no predefined custom <interface> tag -->        
        <xsl:apply-templates select="$job/jobState/data/*[parameter/name=$parametername]/file" mode="dataProcessing"/>
        <xsl:apply-templates select="$job/jobState/data/*[parameter/name=$parametername]/formattedFile" mode="dataProcessing"/>
        <xsl:apply-templates select="$job/jobState/data/*[parameter/name=$parametername]/value" mode="dataProcessing"/>          
        </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xhtml:*[not(@*[ancestor::*[@data-parametername] and (contains(.,'data-url') or contains(.,'data-value'))]|text()[ancestor::*[@data-parametername] and (contains(.,'data-url') or contains(.,'data-value'))])]|@*|text()" mode="pre">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()|text()" mode="pre" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[@*[ancestor::*[@data-parametername] and (contains(.,'data-url') or contains(.,'data-value'))]|text()[ancestor::*[@data-parametername] and (contains(.,'data-url') or contains(.,'data-value'))]]" mode="customInterface">
    <!-- custom <interface> tag handling: setting the parameter name as a variable and then looping over all the values -->
    <xsl:variable name='parametername' select="ancestor-or-self::*[@data-parametername]/@data-parametername"/>
    <xsl:variable name='current' select="."/>
    <xsl:for-each select="$job/jobState/data/*[parameter/name=$parametername]/file/text()">
      <xsl:variable name="result-value" select="."/>      
      <xsl:element name="{local-name($current)}">
        <xsl:apply-templates select="$current/@*|$current/node()|$current/text()" >
          <xsl:with-param name="parametername" select="$parametername" />
          <xsl:with-param name="result-value" select="$result-value" />
        </xsl:apply-templates>
      </xsl:element>
      <a target="_blank" class="saveFileLink" title="save this file" alt="save this file" href="{concat($jobId,'/',$result-value)}?save"> save </a>
    </xsl:for-each>
    <xsl:for-each select="$job/jobState/data/*[parameter/name=$parametername]/value/text()">
      <xsl:element name="{local-name($current)}">
        <xsl:variable name="result-value" select="."/>      
        <xsl:apply-templates select="$current//@*|$current//node()|$current//text()" >
          <xsl:with-param name="parametername" select="$parametername" />
          <xsl:with-param name="result-value" select="$result-value" />
        </xsl:apply-templates>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@*[contains(.,'data-url') or contains(.,'data-value')]" mode="customInterface">
    <!-- custom <interface> tag handling in attribute values: replacing 'data-url' with the actual url of the data and 'data-value' with its actual value (=file name for files) -->
    <xsl:param name="parametername" />
    <xsl:param name="result-value" />
    <xsl:attribute name="{name()}" namespace="{namespace-uri()}">
      <xsl:choose>
        <xsl:when test="contains(.,'data-url')">
          <xsl:value-of select="substring-before(.,'data-url')"/>
          <xsl:value-of select="$jobId" />/<xsl:value-of select="$result-value" />
          <xsl:value-of select="substring-after(.,'data-url')"/>          
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before(.,'data-value')"/>
          <xsl:value-of select="$result-value"/>
          <xsl:value-of select="substring-after(.,'data-value')"/>                    
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>          
  </xsl:template>

  <xsl:template match="text()[contains(.,'data-url') or contains(.,'data-value')]" mode="customInterface">
    <!-- custom <interface> tag handling in text: replacing 'data-url' with the actual url of the data and 'data-value' with its actual value (=file name for files) -->
    <xsl:param name="parametername" />
    <xsl:param name="result-value" />
    <xsl:choose>
      <xsl:when test="contains(.,'data-url')">
        <xsl:value-of select="substring-before(.,'data-url')"/>
        <xsl:value-of select="$jobId" />/<xsl:value-of select="$result-value" />
        <xsl:value-of select="substring-after(.,'data-url')"/>          
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring-before(.,'data-value')"/>
        <xsl:value-of select="$result-value"/>
        <xsl:value-of select="substring-after(.,'data-value')"/>                    
      </xsl:otherwise>
    </xsl:choose>         
  </xsl:template>

	<xsl:template match="@*|node()|text()" priority="-1" mode="customInterface">
	    <xsl:param name="parametername" />
	    <xsl:param name="result-value" />
		<xsl:copy>
			<xsl:apply-templates select="@*|node()|text()" mode="customInterface">
			  <xsl:with-param name="parametername" select="$parametername" />
              <xsl:with-param name="result-value" select="$result-value" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
  <xsl:template match="dataFormat/text()" mode="dataFormats">
    <xsl:copy-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="dataFormat/ref" mode="dataFormats">
    <xsl:variable name="ref"><xsl:value-of select="@param"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$job/jobState/data/*[parameter/name=$ref]/value">
        <xsl:value-of select="normalize-space($job/jobState/data/*[parameter/name=$ref]/value)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(//parameter[name/text()=$ref]/vdef/value)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dataFormat/test" mode="dataFormats">
    <xsl:variable name="ref"><xsl:value-of select="@param"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$job/jobState/data/*[parameter/name=$ref]/value">
        <xsl:variable name="value" select="$job/jobState/data/*[parameter/name=$ref]/value"/>
        <xsl:choose>
          <xsl:when test="@eq and @eq=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@ne and @ne!=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@lt and @lt&lt;$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@le and @le&lt;=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@gt and @gt&gt;$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@ge and @ge&gt;=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="value" select="//parameter[name/text()=$ref]/vdef/value"/>
        <xsl:choose>
          <xsl:when test="@eq and @eq=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@ne and @ne!=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@lt and @lt&lt;$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@le and @le&lt;=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@gt and @gt&gt;$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
          <xsl:when test="@ge and @ge&gt;=$value"><xsl:apply-templates select="child::node()" mode="dataFormats"/></xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="value[//parameter[name/text()=current()/../parameter/name/text()]/type/datatype/class[text()='Choice' or text()='MultipleChoice']]" mode="dataProcessing">
    <xsl:text> </xsl:text><span class="parameter_value"><xsl:value-of select="//parameter[name/text()=current()/../parameter/name/text()]//label[../value/text()=current()/text()]/text()"/></span>
  </xsl:template>

  <xsl:template match="value" mode="dataProcessing">
    <xsl:text> </xsl:text><span class="parameter_value"><xsl:value-of select="text()"/></span>
  </xsl:template>	

  <xsl:template match="file/fmtProgram" mode="dataProcessing"></xsl:template>

  <xsl:template name="fileDisplay">
    <xsl:variable name='resultId' select="concat($jobId,'/',text())"/>
    <fieldset>
      <xsl:attribute name="class">
        minimizable <xsl:if test="name(..)='input'">minimized</xsl:if>
      </xsl:attribute>
      <legend>
        <xsl:if test="local-name(.)='formattedFile'">
          reformatted file produced by <xsl:value-of select="../fmtProgram/text()"></xsl:value-of><xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:value-of select="text()"/>
        <xsl:choose>
          <!-- data format is displayed to the user -->
          <xsl:when test="@fmt">
            (<xsl:value-of select="@fmt"/>)            
          </xsl:when>
          <xsl:when test="not(@fmt) and //parameters/parameter[name/text()=current()/../parameter/name/text()]/type/dataFormat">
            (<xsl:apply-templates select="//parameters//parameter[name/text()=current()/../parameter/name/text()]/type/dataFormat" mode="dataFormats" />)            
          </xsl:when>
        </xsl:choose>
        <a target="_blank" class="saveFileLink" title="save this file" alt="save this file" href="{$resultId}?save"> save </a>
      </legend>
      <span>      
        <span data-filename="{text()}" data-src="{$resultId}">
          <xsl:choose>
            <xsl:when test="//parameter[not(ancestor-or-self::jobState) and name/text()=current()/../parameter/name]/interface">
              <xsl:apply-templates select="//parameter[not(ancestor-or-self::jobState) and name/text()=current()/../parameter/name]/interface" />
            </xsl:when>     
            <xsl:when test="count(//file)+count(//formattedFile)&gt;=20">
              <p class="commentText">
                This file cannot be displayed because too many have been produced by this job.
                <a target="_blank" href="{$resultId}">Click here to display this result in a separate window.</a>
              </p>
            </xsl:when>
            <xsl:when test="@size&lt;=$previewDataLimit">
              <xsl:choose>
	            <xsl:when test="//parameter[name/text()=current()/../parameter/name]/interface[@type='job_output' and not(@generated='true')]">
	              <xsl:apply-templates select="//parameter[name/text()=current()/../parameter/name]/interface[@type='job_output']/*" mode="customInterface">
			      <xsl:with-param name="parametername" select="current()/../parameter/name/text()" />
		              <xsl:with-param name="result-value" select="text()" />
	              </xsl:apply-templates>
	            </xsl:when>     
                <xsl:when test="system-property('xsl:vendor')='Microsoft' or $isIE='True'">
                  <iframe src="{$resultId}">
                    This file cannot be displayed in your browser. Click on the "save" link to download it.                  
                  </iframe>
                </xsl:when>
                <xsl:otherwise>
                  <object data="{$resultId}">
                    This file cannot be displayed in your browser. Click on the "save" link to download it.                  
                  </object>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <p class="commentText">
                The file is too big to be safely displayed here (<xsl:value-of select="round(number(@size) div 1024)"/> KiB).
                <a target="_blank" href="{$resultId}">Click here to display this result in a separate window.</a>
              </p>
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </span>
    </fieldset>    
  </xsl:template>

  <xsl:template match="raw[parent::file]|formattedFile[parent::file]" mode="dataProcessing">
    <xsl:call-template name="fileDisplay" />
  </xsl:template>

  <xsl:template match="file[not(raw or formattedFile)]" mode="dataProcessing">
    <xsl:call-template name="fileDisplay" />
  </xsl:template>

  <xsl:template match="commandLine">
    <fieldset>
      <legend>Command line</legend>
      <div><xsl:value-of select="text()" /></div>
    </fieldset>
  </xsl:template>
  
  <xsl:template match="commandLine">
    <fieldset>
      <legend>Command line</legend>
      <div><xsl:value-of select="text()" /></div>
    </fieldset>
  </xsl:template>
  
  <xsl:template match="paramFiles/file">
    <fieldset>
      <legend>Parameters file:</legend>
      <a href="{$jobId}/{text()}" target="_blank"><xsl:value-of select="text()"/></a>
    </fieldset>
  </xsl:template>

  <xsl:template match="*[@class='commentText']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="id"><xsl:value-of select="concat(@id,'.',$jobPID)" /></xsl:attribute> 
      <xsl:apply-templates select="node()|text()" />
    </xsl:copy>    
  </xsl:template>  

  <xsl:template match="*[@class='blindLink commentToggle']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="href"><xsl:value-of select="concat(@href,'.',$jobPID)" /></xsl:attribute> 
      <xsl:apply-templates select="node()|text()" />
    </xsl:copy>    
  </xsl:template>  
  
</xsl:stylesheet>
