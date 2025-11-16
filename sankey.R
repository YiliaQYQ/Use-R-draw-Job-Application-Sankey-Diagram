# Complete R Script for Job Application Sankey Diagram
# Author: Generated for job application flow visualization
# Date: September 2025 - Updated Version with Offer

# Install required packages if not already installed
# Uncomment the following lines if packages are not installed
# install.packages(c("networkD3", "dplyr", "htmlwidgets"))

# Load required libraries
library(networkD3)
library(dplyr)
library(htmlwidgets)

# ========================================
# DATA PREPARATION
# ========================================

# Define nodes with labels including numbers and color groups
nodes <- data.frame(
  name = c(
    "Applications (406)",                          # 0 - Total applications (updated from 405)
    "Replied (36, 8.9%)",                         # 1 - 36/406 = 8.9% (updated)
    "Rejected (131, 32.3%)",                      # 2 - 131/406 = 32.3% (updated)
    "No Response (239, 58.9%)",                   # 3 - 239/406 = 58.9% (updated, recalculated: 406-36-131=239)
    "1st Interview (21, 58.3%)",                  # 4 - 21/36 = 58.3% (same)
    "OA (1, 2.8%)",                               # 5 - 1/36 = 2.8% (same)
    "2nd Interview (6, 27.3%)",                   # 6 - 6/22 = 27.3% (same, from 21 1st int + 1 OA)
    "3rd Interview (1, 16.7%)",                   # 7 - 1/6 = 16.7% (same)
    "Offers (3, 14.3%)"                           # 8 - 3/21 = 14.3% of all interviews (same)
  ),
  group = c(
    "default",               # 0 - Applications (blue default)
    "replied",               # 1 - Replied (orange)
    "rejected",              # 2 - Rejected (red)
    "no_response",           # 3 - No Response (brown)
    "interview",             # 4 - 1st Interview (green)
    "oa",                    # 5 - OA (cyan)
    "interview_2nd",         # 6 - 2nd Interview (purple)
    "interview_3rd",         # 7 - 3rd Interview (pink)
    "offer"                  # 8 - Offer (gold)
  ),
  stringsAsFactors = FALSE
)

# Create links between nodes with group information for coloring
# Format: source, target, value, group (for link colors)
links <- data.frame(
  source = c(0, 0, 0, 1, 1, 4, 5, 6, 7),  # Source node indices - 5 for OA to 2nd interview
  target = c(1, 2, 3, 4, 5, 6, 6, 7, 8),  # Target node indices - both 4 and 5 go to 6 (2nd interview)
  value = c(36, 131, 239, 21, 1, 5, 1, 1, 3), # Flow values - Updated: no response=239 (406-36-131=239)
  group = c("replied", "rejected", "no_response", "interview", "oa", "interview_2nd", "oa", "interview_3rd", "offer"), # Link color groups
  stringsAsFactors = FALSE
)

# ========================================
# DATA VALIDATION
# ========================================

# Verify the data adds up correctly
total_applications <- 406  # Updated from 405 to 406
calculated_total <- sum(links$value[links$source == 0])
cat("Data Validation:\n")
cat("Expected total applications:", total_applications, "\n")
cat("Calculated total from links:", calculated_total, "\n")

if (total_applications == calculated_total) {
  cat("✓ Data validation passed!\n\n")
} else {
  cat("✗ Data validation failed - check your numbers!\n\n")
}

# ========================================
# COLOR SCHEME DEFINITION
# ========================================

# Define custom color palette using D3 scale
my_color <- 'd3.scaleOrdinal()
  .domain(["default", "replied", "rejected", "no_response", "interview", "oa", "interview_2nd", "interview_3rd", "offer"])
  .range(["#1f77b4", "#ff7f0e", "#d62728", "#8b4513", "#2ca02c", "#00bcd4", "#9467bd", "#e377c2", "#ffd700"])'

# Color mapping explanation:
# "#1f77b4" - Blue (default/applications)
# "#ff7f0e" - Orange (replied)
# "#d62728" - Red (rejected)
# "#8b4513" - Brown (no response)
# "#2ca02c" - Green (1st interviews)
# "#00bcd4" - Cyan (OA)
# "#9467bd" - Purple (2nd interviews)
# "#e377c2" - Pink (3rd interviews)
# "#ffd700" - Gold (offers)

# ========================================
# SANKEY DIAGRAM CREATION
# ========================================

# Create the Sankey diagram
sankey_plot <- sankeyNetwork(
  Links = links,
  Nodes = nodes,
  Source = "source",
  Target = "target",
  Value = "value",
  NodeID = "name",
  NodeGroup = "group",        # Color nodes by group
  LinkGroup = "group",        # Color links by group
  colourScale = my_color,     # Apply custom color scheme
  units = "applications",     # Unit label for tooltips
  fontSize = 18,              # Font size for labels
  nodeWidth = 30,             # Width of node rectangles
  nodePadding = 20,           # Increased vertical spacing between nodes
  margin = list(top = 50, right = 150, bottom = 50, left = 150), # Increased margins for longer lines
  height = 700,               # Increased plot height
  width = 1400,               # Increased plot width for longer lines
  sinksRight = FALSE,         # Keep nodes left-aligned
  fontFamily = "Times New Roman"  # Font family
)

# ========================================
# ENHANCED LINK COLORING (BACKUP METHOD)
# ========================================

# Alternative method to ensure link colors work
# This uses JavaScript to manually color links if LinkGroup doesn't work
sankey_plot_enhanced <- htmlwidgets::onRender(sankey_plot, '
  function(el, x) {
    // Define colors matching our scheme
    var colors = {
      "default": "#1f77b4",
      "replied": "#ff7f0e", 
      "rejected": "#d62728",
      "no_response": "#8b4513",
      "interview": "#2ca02c",
      "oa": "#00bcd4",
      "interview_2nd": "#9467bd",
      "interview_3rd": "#e377c2",
      "offer": "#ffd700"
    };
    
    // Define link groups in order (matching the links data frame)
    var linkGroups = ["replied", "rejected", "no_response", "interview", "oa", "interview_2nd", "oa", "interview_3rd", "offer"];
    
    // Apply colors to links and set font family to Times New Roman
    d3.select(el).selectAll(".link")
      .style("stroke", function(d, i) {
        return colors[linkGroups[i]];
      })
      .style("stroke-opacity", 0.7)
      .style("fill-opacity", 0.7);
    
    // Ensure all text elements use Times New Roman font
    d3.select(el).selectAll("text")
      .style("font-family", "Times New Roman");
  }
')

# ========================================
# DISPLAY OPTIONS
# ========================================

# Option 1: Display basic plot (try this first)
print("Displaying Sankey diagram...")
sankey_plot

# Option 2: If colors don't work, try enhanced version
# Uncomment the line below if you want to use the JavaScript-enhanced version
# sankey_plot_enhanced

# ========================================
# SAVE PLOT (OPTIONAL)
# ========================================

# Save the plot as an HTML file
# Uncomment the following lines to save
# htmlwidgets::saveWidget(sankey_plot, "job_application_sankey.html", selfcontained = TRUE)
# cat("Plot saved as 'job_application_sankey.html'\n")

# ========================================
# SUMMARY STATISTICS
# ========================================

cat("\n", paste(rep("=", 50), collapse=""), "\n")
cat("JOB APPLICATION FLOW ANALYSIS\n")
cat(paste(rep("=", 50), collapse=""), "\n\n")

# Basic statistics
cat("OVERALL METRICS:\n")
cat("Total Applications:", total_applications, "\n")
cat("Applications with Response:", 36 + 131, "(", round(((36+131)/406)*100, 1), "%)\n")
cat("Applications with No Response:", 239, "(", round((239/406)*100, 1), "%)\n\n")

# Response breakdown
cat("RESPONSE BREAKDOWN:\n")
cat("Positive Replies:", 36, "(", round((36/406)*100, 1), "% of total)\n")
cat("Rejections:", 131, "(", round((131/406)*100, 1), "% of total)\n")
cat("No Response:", 239, "(", round((239/406)*100, 1), "% of total)\n\n")

# Conversion rates
cat("CONVERSION RATES:\n")
cat("Reply to Interview Rate:", round((21/36)*100, 1), "% (21 interviews from 36 replies)\n")
cat("1st to 2nd Interview Rate:", round((6/22)*100, 1), "% (6 second interviews from 22 total: 21 first interviews + 1 OA)\n")
cat("2nd to 3rd Interview Rate:", round((1/6)*100, 1), "% (1 third interview from 6 second interviews)\n")
cat("3rd Interview to Offer Rate:", round((3/1)*100, 1), "% (3 offers from 1 third interview)\n")
cat("Overall Interview Rate:", round((21/406)*100, 1), "% (21 interviews from 406 applications)\n")
cat("Overall Success Rate to 2nd Interview:", round((6/406)*100, 1), "% (6 second interviews from 406 applications)\n")
cat("Overall Success Rate to 3rd Interview:", round((1/406)*100, 1), "% (1 third interview from 406 applications)\n")
cat("Overall Offer Rate:", round((3/406)*100, 1), "% (3 offers from 406 applications)\n\n")

# Recommendations
cat("INSIGHTS:\n")
cat("• Response rate is", round(((36+131)/406)*100, 1), "%\n")
cat("• Most applications (", round((239/406)*100, 1), "%) receive no response\n")
cat("• Once you get a reply, interview rate is strong at", round((21/36)*100, 1), "%\n")
cat("• 1st to 2nd interview conversion is", round((6/22)*100, 1), "%\n")
cat("• INCREDIBLE ACHIEVEMENT: You have 3 OFFERS! 🎉🎉🎉\n")
cat("• Your interview pipeline is strengthening - now 6 second interviews\n")
cat("• Recent activity: 1 new application submitted\n")
cat("• You're in an excellent negotiating position with multiple offers\n")
cat("• Outstanding success rate - congratulations on your achievement!\n\n")

cat("Sankey diagram generation complete!\n")

# ========================================
# CHANGES SUMMARY
# ========================================

cat("\nUPDATES MADE:\n")
cat("• Total Applications: 405 → 406 (+1)\n")
cat("• Replied: 36 (no change)\n")
cat("• Rejections: 131 (no change)\n")
cat("• No Response: 238 → 239 (+1)\n")
cat("• 1st Interview: 21 (no change)\n")
cat("• 2nd Interview: 6 (no change)\n")
cat("• 3rd Interview: 1 (no change)\n")
cat("• Offers: 3 (no change) 🎉🎉🎉\n")
cat("• Net effect: 1 new application submitted!\n\n")

# ========================================
# TROUBLESHOOTING GUIDE
# ========================================

cat("TROUBLESHOOTING GUIDE:\n")
cat("If the plot doesn't display:\n")
cat("1. Check that all packages are installed\n")
cat("2. Try: options(viewer = NULL) to force browser display\n")
cat("3. Save as HTML and open manually\n")
cat("4. Check RStudio plots pane or viewer\n")
cat("5. Try restarting R session\n")