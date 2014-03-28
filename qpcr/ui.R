library(shiny)

shinyUI(pageWithSidebar( 
				headerPanel("Real-time quantitative PCR calculator"),
				sidebarPanel(
				HTML("This real-time quantitative PCR calculation is based on the",
					"<a href=\"http://www3.appliedbiosystems.com/cms/groups/mcb_support/documents/generaldocuments/cms_042380.pdf\">procedure</a>",
					"described by Applied Biosystems, using the delta-delta Ct method.<br><br>"),

				HTML("Get an <a href=\"http://eglab.org/~dlow/Book1.txt\">example text file</a> (right-click, save as..)<br>File was generated in Excel, saved as tab-delimited txt.<br><br>"),
				fileInput('file1', 'Choose file',accept=c('text/tab', 'text/tab-separated-values,text/plain', '.txt')),
						
				HTML("1. Normalization gene comes first",
				"i.e. should be in the first row",
				"of the text file.<br>"),
				HTML("2. Columns should be in order of samples.<br>"),
				HTML("eg. sample1_rep1,  sample1_rep2,  sample2_rep1,  sample2_rep2<br>"),
        HTML("3. The current release assumes that all samples have same number of replicates."),
		tags$hr(),
		helpText("Process options:"),
		numericInput("conditions", "Number of samples (if >2, always normalise to sample 1):", 2),
		HTML("<table cellpadding=\"5\"><tr><td>"),
    checkboxInput('normalizegene', 'Normalize to reference gene', TRUE),
    HTML("</td><td>"),
		checkboxInput('normalizesamp', 'Normalize to reference sample', FALSE),
    HTML("</td></tr></table>"),
    helpText("Graphics options:"),
		textInput("ylabel","Y-axis label","Ratio"),
		HTML("<table cellpadding=\"5\"><tr><td>"),
		checkboxInput('displayng', 'Display reference gene', TRUE),
		HTML("</td><td>"),
		checkboxInput('displaync', 'Display reference sample', TRUE),
		HTML("</td></tr><tr><td>"),
		checkboxInput('plotlog2', 'log2 plot', FALSE),
		HTML("</td><td>"),
		checkboxInput('errorbars', 'display error bars', FALSE),
		HTML("</td></tr></table>"),
    downloadButton('downloadPlot', 'Download plot'),
		HTML("<p align=\"right\">Diana Low<br>Epigenetics and Developent<br>Institute of Molecular and Cell Biology, A*STAR<br>",
         "<a href=\"http://eglab.org\">eglab.org</a><br><br>
         Suggestions/improvements? <a href=\"mailto:dlow@imcb.a-star.edu.sg\">Let me know</a>. </p>")
				),
				mainPanel(
						tabsetPanel(
								tabPanel("Input", tableOutput('contents')), 
								tabPanel("Calculated values",
										HTML("Mean and stdev of samples"),
										HTML("<table cellpadding=\"10\"><tr><td>"),tableOutput("mean"),
										HTML("</td><td>"),tableOutput("stdev"),
										HTML("</td></tr></table>"),
										HTML("Normalized values and stdev"),
										HTML("<table cellpadding=\"10\"><tr><td>"),tableOutput("deltact"), 
										HTML("</td><td>"),tableOutput("deltasd"),
										HTML("</td></tr></table>")),
								tabPanel("Plot",plotOutput('graph',width="80%"))
						)
				)
		))


