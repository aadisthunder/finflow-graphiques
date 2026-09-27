import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def create_deck():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_slide_layout = prs.slide_layouts[6]

    # Clean Modern FinTech White / Stickman Palette
    c_bg = RGBColor(255, 255, 255)          # #FFFFFF Pure White
    c_card = RGBColor(248, 250, 252)        # #F8FAFC Light Slate
    c_card_border = RGBColor(226, 232, 240) # #E2E8F0 Subtle Border
    c_title = RGBColor(15, 23, 42)          # #0F172A Deep Charcoal
    c_muted = RGBColor(51, 65, 85)          # #334155 Slate 700
    c_dim = RGBColor(100, 116, 139)         # #64748B Slate 500
    c_green = RGBColor(5, 150, 105)         # #059669 Emerald Green
    c_green_light = RGBColor(16, 185, 129)  # #10B981
    c_green_bg = RGBColor(236, 253, 245)    # #ECFDF5 Emerald Tint
    c_amber = RGBColor(217, 119, 6)         # #D97706 Amber Sunrise
    c_cyan = RGBColor(2, 132, 199)          # #0284C7 Tech Blue
    c_red = RGBColor(220, 38, 38)           # #DC2626 Warning Red

    slides_data = [
        # Slide 1: Hero
        {
            "cat": "₹ FINFLOW (VYAPARSETU)  •  GRAPHIQUES INNOVATION CHALLENGE",
            "title": "FinFlow: Algorithmic Daily Capital & Parametric Climate Resilience",
            "subtitle": "Replacing 300%+ APR predatory debt for 40M unbanked street vendors in India with 4:30 AM algorithmic working capital, daily UPI micro-skimming, and autonomous climate protection.",
            "metrics": [
                ("40M+", "Informal Micro-Vendors in India Driving Daily Commerce", c_amber),
                (">300%", "Effective APR Charged by Informal Loan Sharks", c_red),
                ("₹20", "Flat Daily Cycle Fee for FinFlow Sunrise Capital", c_green),
                ("<60s", "Parametric Weather Insurance Payout Without Paperwork", c_cyan)
            ]
        },
        # Slide 2: Raju's Story (Matches Audio Script Verbatim)
        {
            "cat": "THE REAL-WORLD CRISIS • RAJU'S STORY",
            "title": "The Dawn Capital Deficit & The 300% APR Debt Trap",
            "subtitle": "At 4:30 AM, Raju the fruit vendor needs ₹3,000 for wholesale Mandi inventory. Slow banking forces him into predatory lenders charging over 300% APR, trapping his family in debt.",
            "photo_cards": [
                ("presentation/images/stickman_raju_mandi.jpg", "🌅 4:30 AM Wholesale Mandi", "Needs ₹3,000 wholesale inventory capital before dawn. Traditional banks open at 10 AM.", c_amber),
                ("presentation/images/stickman_loan_shark.jpg", "🩸 >300% APR Predatory Debt", "Slow banking forces him into lenders ('Meter Vaddi') charging over 300% APR, trapping his family in debt.", c_red),
                ("presentation/images/stickman_climate_shock.jpg", "⛈️ Zero Weather Relief", "Monsoon floods and heatwaves rot perishable inventory. With zero relief from lenders, vendors face default.", c_cyan)
            ]
        },
        # Slide 3: Structural Failure (Matches Audio Script Verbatim)
        {
            "cat": "STRUCTURAL FAILURE ANALYSIS",
            "title": "Why Traditional Banking & MFIs Fail Street Vendors",
            "subtitle": "Traditional banks fail informal vendors by demanding collateral, tax returns, and rigid monthly EMIs. When heatwaves or floods hit, lenders offer zero relief, triggering default.",
            "table": [
                ["Dimension", "Commercial Banks", "Microfinance (MFIs)", "FinFlow (VyaparSetu)"],
                ["Underwriting Data", "ITR, CIBIL, audited balance sheets", "Joint liability group peer pressure", "Velocity TrustScore (Zero Collateral)"],
                ["Repayment Rhythm", "Rigid monthly EMI", "Bi-weekly mandatory meetings", "Reverse Micro-Skimming (Daily QR Sales)"],
                ["Disbursement Speed", "5 to 14 Business Days", "2 to 4 Weeks", "Instant (<10s Disbursal at 4:30 AM)"],
                ["Climate Defense", "None (Default penalty applied)", "None (Coercive collection agents)", "Autonomous Parametric Weather Moratorium & Relief"]
            ]
        },
        # Slide 4: 4 Pillars (Matches Audio Script Verbatim)
        {
            "cat": "THE CORE INNOVATION",
            "title": "The Four Pillars of the FinFlow Protocol",
            "subtitle": "FinFlow introduces four pillars: Sunrise Capital for 4:30 AM advances, Reverse Micro-Skimming from daily UPI sales, Suraksha Goolak for emergency savings, and our Parametric Climate Shield for automated weather payouts.",
            "pillars": [
                ("🌅 1. Sunrise Capital", "4:30 AM ADVANCES", "Pre-dawn inventory advances (₹1,500-₹5,000) triggered via regional voice in <5s at flat ₹20 fee (0.8% vs 15%+ loan sharks).", c_amber),
                ("⚡ 2. Reverse Micro-Skimming", "DAILY UPI SALES", "Algorithmic 8%-10% deduction per retail UPI sale. Advance is 100% repaid by dusk with zero debt rollover.", c_green),
                ("🏺 3. Suraksha Goolak", "EMERGENCY SAVINGS", "Weekend sales surpluses automatically route into an interest-bearing liquid fund, building a family rainy-day reserve.", c_cyan),
                ("🛡️ 4. Parametric Climate Shield", "WEATHER PAYOUTS", "Radar alerts (>35mm/hr rain or >43°C heat) auto-freeze daily repayments and disburse ₹600 emergency relief.", c_green)
            ]
        },
        # Slide 5: Raju's Day Walkthrough (Matches Audio Script Verbatim)
        {
            "cat": "USER EXPERIENCE & DAILY JOURNEY",
            "title": "A Day in the Life: How Raju Vends with FinFlow",
            "subtitle": "Raju's day: at 4:30 AM, his smart soundbox disburses 3,000 rupees in seconds. Customer UPI payments auto-settle the loan in micro-slices, leaving his balance clear by evening.",
            "image": "presentation/images/stickman_soundbox_split.jpg",
            "timeline": [
                ("🌅 4:30 AM • Smart Soundbox Disburses ₹3,000 in Seconds", "Soundbox announces: 'Namaste Raju bhai, ₹3,000 Sunrise loan taiyaar hai.' Raju confirms 'Haan'. Disbursed in 5 seconds."),
                ("🛒 11:30 AM • Customer UPI Payments Auto-Settle in Micro-Slices", "Customer pays ₹200 via UPI QR. Soundbox chirps: '₹200 prapt hue. ₹18 loan chukta, ₹2 Goolak mein jama!'"),
                ("⛈️ 2:00 PM • Monsoon Downpour: Weather Oracle Auto-Freezes Debt", "45mm rain detected by IMD radar. Repayments pause automatically, zero penalty, ₹600 emergency payout credited."),
                ("🌙 8:30 PM • Zero-Debt Evening: Balance 100% Clear by Dusk", "Advance 100% cleared. ₹114 saved in Goolak. TrustScore +6. Raju goes home with zero debt.")
            ]
        },
        # Slide 6: Engineering Architecture (Matches Audio Script Verbatim)
        {
            "cat": "ENGINEERING & SYSTEM ARCHITECTURE",
            "title": "Engineered on India's Digital Public Infrastructure",
            "subtitle": "Built on India's Digital Public Infrastructure, FinFlow integrates OCEN 4.0, real-time UPI settlement webhooks, and our Velocity TrustScore that replaces traditional credit scores.",
            "image": "presentation/images/stickman_soundbox_split.jpg",
            "bullets": [
                ("⚡ Sub-250ms Real-Time Webhook Engine", "Instantaneous multi-split routing between vendor spendable wallet, SFB loan vault, and Goolak on NPCI settlement webhooks."),
                ("🧠 Velocity TrustScore ML Model (Replaces Credit Scores)", "Evaluates 90-day transaction regularity, mandi geo-location stamps, ticket size, and peer rings without CIBIL."),
                ("📡 Parametric Weather Oracle", "Telemetry integration with Open-Meteo & IMD radar evaluates rainfall (mm/hr) and heat index across 1km² municipal polygons.")
            ]
        },
        # Slide 7: Unit Economics (Matches Audio Script Verbatim: Flat 20-rupee fee, 86.8% margin, 14.8x LTV/CAC)
        {
            "cat": "BUSINESS MODEL & UNIT ECONOMICS",
            "title": "High-Margin, Asset-Light Business Model",
            "subtitle": "Our business model is high-margin and asset-light. A flat 20-rupee fee per daily cycle delivers an 86.8 percent net margin and a 14.8 times lifetime value to CAC ratio.",
            "metrics": [
                ("₹20", "Flat Fee per Daily Cycle (₹3,000 Advance)", c_amber),
                ("86.8%", "Net Contribution Margin per Vendor Cycle", c_green),
                ("14.8x", "Lifetime Value (LTV) to CAC Ratio", c_cyan),
                ("< 0.8%", "Target NPL Default Rate via Micro-Skimming", c_green)
            ]
        },
        # Slide 8: Market Opportunity (Matches Audio Script Verbatim: 40M vendors, $18B demand, 8 trading hubs, $18M ARR)
        {
            "cat": "MARKET OPPORTUNITY & REVENUE SCALE",
            "title": "40M Vendors • $18 Billion Daily Capital Demand",
            "subtitle": "Forty million vendors represent an 18-billion-dollar working capital demand. Scaling to 250,000 merchants across eight trading hubs unlocks 18 million dollars in annual recurring revenue.",
            "market_cards": [
                ("$18 Billion", "40M Vendors Demand", "40 Million informal street vendors in India circulating over $12B daily with zero access to bank capital.", c_cyan),
                ("8 Hubs", "8 Trading Hubs", "Dense metropolitan trading clusters: Delhi NCR, Mumbai, Bengaluru, Hyderabad, Ahmedabad, Kolkata, Lucknow, Indore.", c_amber),
                ("$18M ARR", "Annual Recurring Revenue", "Scaling to 250,000 active micro-merchants across 8 trading hubs unlocks $18 Million in high-margin ARR.", c_green)
            ]
        },
        # Slide 9: 15-Month Roadmap (Matches Audio Script Verbatim: 1,000 vendors, Small Finance Banks, 100,000 merchants across 15 states)
        {
            "cat": "EXECUTION & GO-TO-MARKET",
            "title": "15-Month Scaled Implementation Roadmap",
            "subtitle": "Our 15-month roadmap pilots with 1,000 vendors in Delhi's Azadpur Mandi, scales with Small Finance Banks, and expands nationally to 100,000 merchants across fifteen states.",
            "phases": [
                ("Phase 1: Pilot with 1,000 Vendors in Delhi's Azadpur Mandi (M1-3)", "Deploy pilot with 1,000 vendors in Azadpur Mandi (Delhi). Validate sub-250ms auto-split and vernacular voice models.", c_amber),
                ("Phase 2: Scale with Small Finance Banks via OCEN 4.0 (M4-8)", "Direct OCEN 4.0 integration with 2 Small Finance Banks; partner with micro-insurance underwriters for Parametric Rain Shield.", c_cyan),
                ("Phase 3: National Scale to 100,000 Merchants Across 15 States (M9-15)", "Scale to 100,000 active vendors across 15 states. Introduce automated micro-pensions and group purchasing discounts.", c_green)
            ]
        },
        # Slide 10: Conclusion (Matches Audio Script Verbatim: Saves ₹7,500/month, Restoring Economic Freedom & Dignity)
        {
            "cat": "GRAPHIQUES INNOVATION CHALLENGE • CONCLUSION",
            "title": "Redesigning the World: Dignity for the Hands That Feed Us",
            "subtitle": "FinFlow saves vendors over ₹7,500 every month, restoring economic freedom and dignity to the backbone of our economy. Thank you.",
            "conclusion_split": {
                "image": "presentation/images/stickman_dignity_restored.jpg",
                "badge": "🌅 SAVES OVER ₹7,500 EVERY MONTH",
                "pillars": [
                    ("💰 Restoring Economic Freedom", "Saves the average street vendor over ₹7,500 every month in avoided loan shark interest—directly raising disposable income by 35%.", c_green),
                    ("🛡️ Climate Resilience & Protection", "Autonomous weather safety net ensures heatwaves and floods no longer push micro-entrepreneurs into bankruptcy.", c_cyan),
                    ("🤝 Dignity for the Backbone of Our Economy", "Voice-first vernacular interaction empowers 40M+ non-literate vendors as equal participants in digital finance.", c_amber)
                ]
            }
        }
    ]

    for s_idx, data in enumerate(slides_data):
        slide = prs.slides.add_slide(blank_slide_layout)
        
        # White Clean Background
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = c_bg
        bg.line.fill.background()

        # Category Badge
        cat_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.45), Inches(11.5), Inches(0.35))
        tf_cat = cat_box.text_frame
        tf_cat.word_wrap = True
        p_cat = tf_cat.paragraphs[0]
        p_cat.text = data["cat"]
        p_cat.font.size = Pt(11)
        p_cat.font.bold = True
        p_cat.font.color.rgb = c_green

        # Slide Title
        title_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.8), Inches(11.7), Inches(0.85))
        tf_title = title_box.text_frame
        tf_title.word_wrap = True
        p_title = tf_title.paragraphs[0]
        p_title.text = data["title"]
        p_title.font.size = Pt(28)
        p_title.font.bold = True
        p_title.font.color.rgb = c_title

        # Slide Subtitle
        sub_box = slide.shapes.add_textbox(Inches(0.8), Inches(1.65), Inches(11.7), Inches(0.65))
        tf_sub = sub_box.text_frame
        tf_sub.word_wrap = True
        p_sub = tf_sub.paragraphs[0]
        p_sub.text = data["subtitle"]
        p_sub.font.size = Pt(13)
        p_sub.font.color.rgb = c_muted

        # Render Metrics (Slide 1, Slide 7)
        if "metrics" in data:
            card_w = Inches(2.7)
            card_h = Inches(4.2)
            card_y = Inches(2.45)
            for m_i, (num, lbl, col) in enumerate(data["metrics"]):
                card_x = Inches(0.8 + m_i * 2.95)
                c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, card_x, card_y, card_w, card_h)
                c_shape.fill.solid()
                c_shape.fill.fore_color.rgb = c_card
                c_shape.line.color.rgb = c_card_border
                
                tb = slide.shapes.add_textbox(card_x + Inches(0.2), card_y + Inches(0.5), card_w - Inches(0.4), card_h - Inches(1.0))
                tf = tb.text_frame
                tf.word_wrap = True
                
                p_num = tf.paragraphs[0]
                p_num.text = num
                p_num.font.size = Pt(38)
                p_num.font.bold = True
                p_num.font.color.rgb = col
                
                p_lbl = tf.add_paragraph()
                p_lbl.text = lbl
                p_lbl.font.size = Pt(12)
                p_lbl.font.color.rgb = c_muted

        # Render Photo Cards (Slide 2 - Raju's Story)
        elif "photo_cards" in data:
            card_w = Inches(3.7)
            card_y = Inches(2.45)
            card_h = Inches(4.5)
            img_h = Inches(2.4)
            
            for pc_i, (img_path, h_txt, b_txt, col) in enumerate(data["photo_cards"]):
                card_x = Inches(0.8 + pc_i * 3.95)
                
                c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, card_x, card_y, card_w, card_h)
                c_shape.fill.solid()
                c_shape.fill.fore_color.rgb = c_card
                c_shape.line.color.rgb = col
                
                if os.path.exists(img_path):
                    slide.shapes.add_picture(img_path, card_x + Inches(0.1), card_y + Inches(0.1), card_w - Inches(0.2), img_h)
                
                tb = slide.shapes.add_textbox(card_x + Inches(0.2), card_y + img_h + Inches(0.2), card_w - Inches(0.4), card_h - img_h - Inches(0.3))
                tf = tb.text_frame
                tf.word_wrap = True
                
                p_h = tf.paragraphs[0]
                p_h.text = h_txt
                p_h.font.size = Pt(14)
                p_h.font.bold = True
                p_h.font.color.rgb = c_title
                
                p_b = tf.add_paragraph()
                p_b.text = b_txt
                p_b.font.size = Pt(11)
                p_b.font.color.rgb = c_muted

        # Render Table (Slide 3)
        elif "table" in data:
            rows = len(data["table"])
            cols = len(data["table"][0])
            tbl_shape = slide.shapes.add_table(rows, cols, Inches(0.8), Inches(2.45), Inches(11.7), Inches(4.3))
            tbl = tbl_shape.table
            tbl.columns[0].width = Inches(2.2)
            tbl.columns[1].width = Inches(3.0)
            tbl.columns[2].width = Inches(3.0)
            tbl.columns[3].width = Inches(3.5)
            
            for r_idx, row in enumerate(data["table"]):
                for col_idx, cell_text in enumerate(row):
                    cell = tbl.cell(r_idx, col_idx)
                    cell.text = cell_text
                    cell.fill.solid()
                    if r_idx == 0:
                        cell.fill.fore_color.rgb = RGBColor(5, 150, 105) if col_idx == 3 else RGBColor(241, 245, 249)
                    else:
                        cell.fill.fore_color.rgb = c_green_bg if col_idx == 3 else c_card
                    p = cell.text_frame.paragraphs[0]
                    p.font.size = Pt(11 if r_idx > 0 else 12)
                    p.font.bold = (r_idx == 0 or col_idx == 0 or col_idx == 3)
                    p.font.color.rgb = RGBColor(255, 255, 255) if (r_idx == 0 and col_idx == 3) else (RGBColor(6, 95, 70) if col_idx == 3 else c_title)

        # Render Pillars (Slide 4)
        elif "pillars" in data:
            for p_i, (h_txt, tag, desc, col) in enumerate(data["pillars"]):
                col_i = p_i % 2
                row_i = p_i // 2
                card_x = Inches(0.8 + col_i * 5.95)
                card_y = Inches(2.45 + row_i * 2.2)
                card_w = Inches(5.75)
                card_h = Inches(2.0)
                
                c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, card_x, card_y, card_w, card_h)
                c_shape.fill.solid()
                c_shape.fill.fore_color.rgb = c_card
                c_shape.line.color.rgb = col
                
                tb = slide.shapes.add_textbox(card_x + Inches(0.2), card_y + Inches(0.2), card_w - Inches(0.4), card_h - Inches(0.4))
                tf = tb.text_frame
                tf.word_wrap = True
                
                p_h = tf.paragraphs[0]
                p_h.text = f"{h_txt}  [{tag}]"
                p_h.font.size = Pt(15)
                p_h.font.bold = True
                p_h.font.color.rgb = c_title
                
                p_d = tf.add_paragraph()
                p_d.text = desc
                p_d.font.size = Pt(12)
                p_d.font.color.rgb = c_muted

        # Render Timeline + Image (Slide 5)
        elif "timeline" in data:
            tl_x = Inches(0.8)
            tl_w = Inches(6.8)
            for t_i, (time_lbl, desc) in enumerate(data["timeline"]):
                tb = slide.shapes.add_textbox(tl_x, Inches(2.45 + t_i * 1.1), tl_w, Inches(1.0))
                tf = tb.text_frame
                tf.word_wrap = True
                p_t = tf.paragraphs[0]
                p_t.text = time_lbl
                p_t.font.size = Pt(13)
                p_t.font.bold = True
                p_t.font.color.rgb = c_amber if t_i == 0 else (c_green if t_i == 1 else (c_red if t_i == 2 else c_cyan))
                
                p_d = tf.add_paragraph()
                p_d.text = desc
                p_d.font.size = Pt(11)
                p_d.font.color.rgb = c_muted
                
            if os.path.exists(data["image"]):
                slide.shapes.add_picture(data["image"], Inches(8.0), Inches(2.45), Inches(4.5), Inches(4.3))

        # Render Architecture + Image (Slide 6)
        elif "bullets" in data:
            if os.path.exists(data["image"]):
                slide.shapes.add_picture(data["image"], Inches(0.8), Inches(2.45), Inches(5.5), Inches(4.3))
            
            b_x = Inches(6.6)
            b_w = Inches(5.9)
            for b_i, (b_title, b_desc) in enumerate(data["bullets"]):
                card_y = Inches(2.45 + b_i * 1.45)
                c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, b_x, card_y, b_w, Inches(1.35))
                c_shape.fill.solid()
                c_shape.fill.fore_color.rgb = c_card
                c_shape.line.color.rgb = c_card_border
                
                tb = slide.shapes.add_textbox(b_x + Inches(0.15), card_y + Inches(0.15), b_w - Inches(0.3), Inches(1.1))
                tf = tb.text_frame
                tf.word_wrap = True
                p_bt = tf.paragraphs[0]
                p_bt.text = b_title
                p_bt.font.size = Pt(13)
                p_bt.font.bold = True
                p_bt.font.color.rgb = c_title
                
                p_bd = tf.add_paragraph()
                p_bd.text = b_desc
                p_bd.font.size = Pt(11)
                p_bd.font.color.rgb = c_muted

        # Render Market Cards (Slide 8 - $18B Demand, 8 Hubs, $18M ARR)
        elif "market_cards" in data:
            card_w = Inches(3.7)
            card_h = Inches(4.2)
            card_y = Inches(2.45)
            for mc_i, (stat_txt, tag_txt, desc_txt, col) in enumerate(data["market_cards"]):
                card_x = Inches(0.8 + mc_i * 3.95)
                c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, card_x, card_y, card_w, card_h)
                c_shape.fill.solid()
                c_shape.fill.fore_color.rgb = c_card
                c_shape.line.color.rgb = col
                
                tb = slide.shapes.add_textbox(card_x + Inches(0.25), card_y + Inches(0.4), card_w - Inches(0.5), card_h - Inches(0.8))
                tf = tb.text_frame
                tf.word_wrap = True
                
                p_tag = tf.paragraphs[0]
                p_tag.text = tag_txt.upper()
                p_tag.font.size = Pt(11)
                p_tag.font.bold = True
                p_tag.font.color.rgb = col
                
                p_stat = tf.add_paragraph()
                p_stat.text = stat_txt
                p_stat.font.size = Pt(36)
                p_stat.font.bold = True
                p_stat.font.color.rgb = c_title
                
                p_desc = tf.add_paragraph()
                p_desc.text = desc_txt
                p_desc.font.size = Pt(12)
                p_desc.font.color.rgb = c_muted

        # Render Phases (Slide 9)
        elif "phases" in data:
            for ph_i, (ph_title, ph_desc, col) in enumerate(data["phases"]):
                p_y = Inches(2.45 + ph_i * 1.5)
                c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), p_y, Inches(11.7), Inches(1.35))
                c_shape.fill.solid()
                c_shape.fill.fore_color.rgb = c_card
                c_shape.line.color.rgb = col
                
                tb = slide.shapes.add_textbox(Inches(1.0), p_y + Inches(0.15), Inches(11.3), Inches(1.05))
                tf = tb.text_frame
                tf.word_wrap = True
                p_pt = tf.paragraphs[0]
                p_pt.text = ph_title
                p_pt.font.size = Pt(14)
                p_pt.font.bold = True
                p_pt.font.color.rgb = c_title
                
                p_pd = tf.add_paragraph()
                p_pd.text = ph_desc
                p_pd.font.size = Pt(11.5)
                p_pd.font.color.rgb = c_muted

        # Render Conclusion Split (Slide 10 - Saves ₹7,500/mo & Dignity)
        elif "conclusion_split" in data:
            split_info = data["conclusion_split"]
            img_p = split_info["image"]
            
            if os.path.exists(img_p):
                slide.shapes.add_picture(img_p, Inches(0.8), Inches(2.45), Inches(5.8), Inches(4.3))
                
            c_x = Inches(6.9)
            c_w = Inches(5.6)
            for pi_i, (pi_title, pi_desc, col) in enumerate(split_info["pillars"]):
                c_y = Inches(2.45 + pi_i * 1.45)
                c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, c_x, c_y, c_w, Inches(1.35))
                c_shape.fill.solid()
                c_shape.fill.fore_color.rgb = c_card
                c_shape.line.color.rgb = col
                
                tb = slide.shapes.add_textbox(c_x + Inches(0.2), c_y + Inches(0.15), c_w - Inches(0.4), Inches(1.05))
                tf = tb.text_frame
                tf.word_wrap = True
                p_t = tf.paragraphs[0]
                p_t.text = pi_title
                p_t.font.size = Pt(14)
                p_t.font.bold = True
                p_t.font.color.rgb = c_title
                
                p_d = tf.add_paragraph()
                p_d.text = pi_desc
                p_d.font.size = Pt(11)
                p_d.font.color.rgb = c_muted

    output_path = "FinFlow_Pitch_Deck.pptx"
    prs.save(output_path)
    print(f"Presentation saved successfully to {output_path} ({os.path.getsize(output_path)} bytes)")

if __name__ == "__main__":
    create_deck()
