library(shiny)

shinyUI(pageWithSidebar( 
				headerPanel("shiny! qPCR"),
				sidebarPanel(
				HTML("This real-time quantitative PCR calculation is based on the",
					"<a href=\"http://www3.appliedbiosystems.com/cms/groups/mcb_support/documents/generaldocuments/cms_042380.pdf\">procedure</a>",
					"described by Applied Biosystems, using the delta-delta Ct method.<br><br>"),
				fileInput('file1', tags$h4('Choose file'),accept=c('text/tab', 'text/tab-separated-values,text/plain', '.txt')),
		tags$h4("Process options:"),
		numericInput("conditions", "Number of samples (if >2, always normalise to sample 1):", 2),
		HTML("<table cellpadding=\"5\"><tr><td>"),
    checkboxInput('normalizegene', 'Normalize to reference gene', TRUE),
    HTML("</td><td>"),
		checkboxInput('normalizesamp', 'Normalize to reference sample', FALSE),
    HTML("</td></tr></table>"),
    tags$h4("Graphics options:"),
		textInput("ylabel","Y-axis label","Ratio"),
		HTML("<table cellpadding=\"5\"><tr><td>"),
		checkboxInput('displayng', 'Display reference gene', TRUE),
		HTML("</td><td>"),
		checkboxInput('displaync', 'Display reference sample', TRUE),
		HTML("</td></tr><tr><td>"),
		checkboxInput('plotlog2', 'log2 plot', TRUE),
		HTML("</td><td>"),
		checkboxInput('errorbars', 'display error bars', FALSE),
		HTML("</td></tr></table>"),
    downloadButton('downloadPlot', 'Download plot'),
		tags$hr(),
		helpText(HTML("This <a href=\"http://shiny.rstudio.com\">R Shiny</a> app was first developed for lab use, and then further improvised as part of the Coursera's 
             <a href=\"https://www.coursera.org/course/devdataprod\">Developing Data Products</a> project. ")),
		HTML("<p align=\"right\">Diana Low<br>Epigenetics and Development<br>Institute of Molecular and Cell Biology, A*STAR<br>",
         "<a href=\"http://eglab.org\">eglab.org</a><br><br>
         Suggestions/improvements? <a href=\"mailto:dlow@imcb.a-star.edu.sg\">Let me know</a>. </p>")
				),
				mainPanel(
						tabsetPanel(
								tabPanel("Instructions",
								         HTML("<h3>Formatting your input file</h3>
                              <p><span style=\"color:#990000;font-weight:bold;\">**The current release assumes that all samples have same number of replicates. <br>
                              I hope to write a more comprehensive one in the future!</span></p>
                              Some notes <ul>
                              <li>List the gene you want to normalize against on the first row in your table.</li>
                              <li>Columns should be in order of samples. eg. sample1_rep1,  sample1_rep2,  sample2_rep1,  sample2_rep2</li>
                              <li>The available example file provided below was generated in Excel, and saved as tab-delimited text.</li>
                              </ul>
                              <br>  
    			                    <a href=\"https://raw.githubusercontent.com/dianalow/shiny_apps/master/qpcr_example.txt\">Example text file</a> (right-click, save as..)<br>
                              <img src=\"http://i.imgur.com/ybZORQP.png\">
                              <br><br>
                              </p>
                              <p>Once a file has been uploaded,
                              <ul>
                              <li>Raw data will be displayed in the <span style=\"color:#0099FF;font-weight:bold;\">Input</span> tab</li>
                              <li>Calculated values will be in the <span style=\"color:#0099FF;font-weight:bold;\">Calculated values</span> tab</li>
                              <li>A figure will be generated in the <span style=\"color:#0099FF;font-weight:bold;\">Plot</span> tab</li>
                              </ul>
                              </p>
                              <p>Display options can be tweaked in the panel on the left.</p>")
                         ), 
                tabPanel("Input",
                         HTML("<h3>Input table</h3>"),
                         tableOutput('contents')),
								tabPanel("Calculated values",
                    HTML("<h3>Calculated values</h3>
										      <h4>Mean and standard deviation of samples</h4>"),
										HTML("<table cellpadding=\"10\"><tr><td>"),tableOutput("mean"),
										HTML("</td><td>"),tableOutput("stdev"),
										HTML("</td></tr></table>"),
										HTML("<h4>Normalized values and standard deviation</h4>"),
										HTML("<table cellpadding=\"10\"><tr><td>"),tableOutput("deltact"), 
										HTML("</td><td>"),tableOutput("deltasd"),
										HTML("</td></tr></table>")),
								tabPanel("Plot",plotOutput('graph',width="80%")),
								tabPanel("What are Ct values?",
                         HTML("<h3>What are Ct values?</h3>
                              <p>Quantative PCR is a method to determine the amount of particular gene in a sample. The Ct value, or threshold cycle,
                              is a relative measure of the concentration of target in the PCR reaction.</p>
                              <p>Typically we would:
                              <ol>
                              <li>Normalise a gene of interest to a \"housekeeper\" gene (i.e. a gene used as baseline, known to be unchanging)</li>
                              <li>Compare this value to the same gene in another sample (eg. treated vs untreated)</li>
                              </ol>
                              This way we can compare the change in the gene in terms of fold difference.
                              </p>
                              <p>For more information and extensive calculations, visit
                              <br><a href=\"http://www.lifetechnologies.com/sg/en/home/life-science/pcr/real-time-pcr/qpcr-education/pcr-understanding-ct-application-note.html\">http://www.lifetechnologies.com/sg/en/home/life-science/pcr/real-time-pcr/qpcr-education/pcr-understanding-ct-application-note.html</a>
                              <br><a href=\"http://www3.appliedbiosystems.com/cms/groups/mcb_support/documents/generaldocuments/cms_042380.pdf\">http://www3.appliedbiosystems.com/cms/groups/mcb_support/documents/generaldocuments/cms_042380.pdf</a>
                              </p>"))
						)
				)
		))


