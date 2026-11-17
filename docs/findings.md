# Findings

Results from the analysis queries in `sql/analysis/`. Numbers are snapshots of the run date shown. Rerun the queries after any rebuild of the marts.

All growth figures are **liters per adult (21+)**, not total liters, so they measure change in demand rather than population growth. CAGR is the compound annual growth rate from 2019 (the last full pre-COVID year) to 2025 (the last full year of data), over 6 years.

---

## A. Growth: where is demand rising?

<!-- **Run date:** 2026-11-13 -->
**Queries:** `sql/analysis/a1_growth_state.sql` (A1), `a2_growth_county.sql` / `marts.growth_opportunities` (A2–A5), same-store and supplier checks (A6–A8)

### Headlines

1. **Tequila/Mezcal is the only major spirit family growing per adult statewide**, at about **5.8% a year** (0.41 → 0.57 L per adult). RTD/Cocktails grew modestly (2.4% a year). Everything else was flat or shrinking: vodka flat, whiskey and liqueur down about 1% a year, rum and gin down about 3%, brandy down about 6%.
2. **Tequila's growth is broad-based, not driven by a few counties.** The median county grew tequila by 4.6% a year. Of the nine families, only tequila, Other, RTD/Cocktails and (barely) vodka grew in the typical county.
3. **In volume, the biggest single opportunity is tequila in Polk County** (Des Moines): about 103,000 more liters in 2025 than 2019 per-adult rates would give. The tequila trend also adds the most volume in Linn, Scott and Black Hawk, Iowa's other large metro counties.
4. **Clinton County's "growth" is one new store, not rising demand.** Clinton ranks in the top 10 in 7 of 9 families, and its per-adult sales roughly doubled across almost every family. This is because **Another Round (DeWitt)**, which had no sales in 2019, sold about 300,500 liters in 2025. This one store accounts for more than the county's whole increase (about 308,000 → 549,000 liters). Without it, Clinton's stores sold about 249,000 liters in 2025, **roughly 19% less than in 2019**, and most established stores declined (Hy-Vee −32%, DeWitt Travel Mart −87%). Another Round opened in March 2020 next door to DeWitt Travel Mart (622 vs 630 6th Ave). Travel Mart's liquor sales fell from about 3,400 liters a month in 2019 to about 500–800 a month within weeks and never recovered, so Another Round clearly took that store's liquor customers. But that accounts for only about 2,700 liters a month, against Another Round's steady 25,000–28,000 a month since 2022. Even if every liter that Clinton County's existing stores lost (their 2025 volume was about 93,000 liters below 2019, see A6) went to Another Round, that would explain only about a third of its volume. **Most of its sales come from outside the county or from on-premise buyers (bars and restaurants)**, so it shouldn't be read as Clinton residents drinking more.
5. **At existing stores, sales are shrinking almost everywhere.** Counting only stores that sold all year in both 2019 and 2025 ("same-store" growth, total liters), **81 of 97 counties declined**, including every large metro except Scott: Polk −2.3% a year, Black Hawk −2.2%, Story −2.8%, Dallas −2.7%, Linn −1.1%. Combined with Headline 1, this suggests that where county totals held up, much of it came from **new stores opening**, not from existing stores selling more, so new outlets are likely taking share from established ones. That's a store-mix story the county totals alone would hide.
6. **About 15 stores that look like bar and restaurant suppliers sell about 11% of Iowa's volume and distort county comparisons.** Their bottle mix (mostly 1 L bottles, few minis or handles) matches on-premise buying. Removing them drops Clinton from 2nd to 41st in liters per adult and moves Polk, Black Hawk and Linn out of the top 10 (A8). Their sales fell about 25% in 2020 while retail rose about 12%, the clearest COVID signal in the data.

### A1. Statewide liters per adult by family, 2019 vs 2025

| Family | 2019 (L/adult) | 2025 (L/adult) | CAGR |
|---|---:|---:|---:|
| Tequila/Mezcal | 0.41 | 0.57 | +5.8% |
| Other | 0.34 | 0.41 | +3.2% |
| RTD/Cocktails | 0.34 | 0.40 | +2.4% |
| Vodka | 3.11 | 3.07 | −0.2% |
| Whiskey | 2.61 | 2.45 | −1.1% |
| Liqueur | 1.30 | 1.21 | −1.2% |
| Rum | 1.15 | 0.95 | −3.1% |
| Gin | 0.24 | 0.20 | −3.2% |
| Brandy | 0.31 | 0.21 | −5.9% |

Vodka and whiskey are still by far the largest families (about 3 and 2.5 L per adult); tequila is growing from a much smaller base. "Other" is mostly catch-all categories (Temporary & Specialty Packages, Special Order Items, neutral grain spirits, distilled spirits specialty. See DQ-15.) An item-level check shows its growth is **mostly products filed outside their natural family**:

| What grew in "Other" (2019 → 2025 liters) | Category it's filed under | Natural family |
|---|---|---|
| Crown Royal Blackberry (0 → 100,807), Crown Royal Chocolate (0 → 35,102) | Temporary & Specialty Packages | Whiskey |
| Tortilla Gold (0 → 82,770), Juarez Gold (0 → 35,986), Don Agave, Montezuma Blue (about 26,000 combined) | Distilled spirits specialty ("DSS") | Agave spirits (budget tequila-style) |
| Members Mark Vodka (106,512 → 116,928) | Special Order Items | Vodka |
| Captain Morgan gift packs, holiday packs, egg nogs | Temporary & Specialty Packages | Rum / liqueur / mixed |
| Ole Smoky flavored moonshines (several items up 2–25×) | Neutral grain spirits, flavored | Genuinely "other": a real flavored-moonshine trend |
| Soju (Soonhari, Jinro: about 17,000 L across items) | Distilled spirits specialty | Other; small |

**What this means for the family results:** the direction of every headline holds, but two families are likely understated. Agave-style "DSS" products sold about 145,000 L in 2025, roughly 14% of tequila's volume, so tequila's real growth is probably *higher* than +5.8–6.4%. Crown Royal Blackberry and Chocolate add about 3% to whiskey's 2025 volume, so whiskey's decline is probably a little *milder* (closer to −0.7% a year than −1.2%). The tequila headline is therefore conservative. Remapping the largest items to their natural family (an item-level override seed) would correct this; it's listed under Checks.

**RTD/Cocktails is narrower than the national RTD category.** It covers spirits-based premixes sold through the state (bottles, jugs, pouches; average bottle about 1.3–1.6 L). Since 2019, canned cocktails up to 15% ABV are distributed as beer in Iowa, and malt- and wine-based RTDs were never part of this data, so the RTD boom reported nationally isn't captured here.

### A2. Typical-county growth by family

| Family | Counties | Min | Median | Max |
|---|---:|---:|---:|---:|
| Tequila/Mezcal | 76 | −13.6% | +4.6% | +19.3% |
| Other | 78 | −7.8% | +4.4% | +37.5% |
| RTD/Cocktails | 78 | −7.4% | +2.0% | +16.6% |
| Vodka | 99 | −6.2% | +0.9% | +16.4% |
| Liqueur | 98 | −9.6% | −0.8% | +24.2% |
| Whiskey | 99 | −6.1% | −1.3% | +20.7% |
| Rum | 95 | −11.2% | −2.9% | +7.6% |
| Gin | 48 | −8.2% | −4.2% | +10.2% |
| Brandy | 57 | −13.1% | −4.9% | +5.9% |

"Counties" is the number of counties that pass the minimum-size filter (at least 1,000 liters of that family in 2025), so smaller families like gin and brandy cover fewer counties.

### A3. Largest opportunities by volume

Added liters = (change in liters per adult) × 2025 adults: the extra 2025 volume from higher per-adult demand, excluding population growth.

| County | Family | CAGR | Added liters | 2025 liters |
|---|---|---:|---:|---:|
| Polk | Tequila/Mezcal | +4.9% | 102,953 | 410,369 |
| Clinton | Vodka | +9.5% | 70,531 | 167,524 |
| Clinton | Whiskey | +11.4% | 58,081 | 121,948 |
| Clinton | Liqueur | +12.1% | 49,985 | 100,490 |
| Marshall | Other | +37.5% | 41,026 | 48,143 |
| Linn | Tequila/Mezcal | +7.3% | 40,295 | 116,627 |
| Polk | RTD/Cocktails | +2.9% | 31,958 | 200,720 |
| Scott | Tequila/Mezcal | +5.3% | 30,547 | 115,290 |
| Clinton | Tequila/Mezcal | +19.3% | 30,327 | 46,432 |
| Polk | Other | +2.6% | 28,688 | 201,943 |
| Pottawattamie | Other | +10.1% | 25,437 | 57,882 |
| Black Hawk | Tequila/Mezcal | +6.0% | 24,275 | 82,707 |
| Clinton | Rum | +7.6% | 23,035 | 64,604 |
| Scott | RTD/Cocktails | +5.1% | 20,376 | 78,609 |
| Cerro Gordo | Vodka | +1.7% | 16,587 | 170,020 |

Excluding Clinton and the "Other" rows, the list is dominated by **tequila and RTD/Cocktails in the large metro counties**, which is consistent with Headline 1.

### A4. Counties growing across many families

| County | Families in top 10 | Avg CAGR |
|---|---:|---:|
| Clinton | 7 | +9.3% |
| Marshall | 6 | +7.6% |
| Jefferson | 5 | +5.3% |
| Ringgold | 4 | +4.8% |
| Benton | 4 | +3.8% |
| Jackson | 4 | +3.8% |
| Fremont | 3 | +20.4% |
| Worth | 3 | +9.1% |
| Clarke | 3 | +3.6% |
| Dallas | 3 | +3.5% |
| Henry | 3 | +2.5% |
| Washington | 3 | +1.4% |

Broad growth in one county across unrelated families usually points to a store-level change (an opening, closure or expansion) rather than changing tastes. Clinton, Marshall and Fremont should be checked at store level (see below).

### A5. Top 5 counties by CAGR within each family

| Family | #1 | #2 | #3 | #4 | #5 |
|---|---|---|---|---|---|
| Tequila/Mezcal | Clinton +19.3% | Marshall +17.7% | Benton +16.6% | Jackson +14.0% | Greene +13.3% |
| RTD/Cocktails | Allamakee +16.6% | Marshall +12.2% | Clarke +8.6% | Washington +7.7% | Shelby +7.5% |
| Other | Marshall +37.5% | Humboldt +32.7% | Worth +26.2% | Guthrie +25.3% | Hancock +25.2% |
| Vodka | Fremont +16.4% | Clinton +9.5% | Jefferson +8.2% | Ringgold +6.9% | Van Buren +6.6% |
| Whiskey | Fremont +20.7% | Clinton +11.4% | Ringgold +5.6% | Wayne +4.7% | Decatur +4.5% |
| Liqueur | Fremont +24.2% | Worth +12.8% | Clinton +12.1% | Adams +10.8% | Audubon +6.7% |
| Rum | Clinton +7.6% | Jackson +6.6% | Wayne +4.6% | Clayton +1.4% | Worth +1.0% |
| Gin | Clarke +10.2% | Clinton +9.6% | Dallas +2.0% | Jefferson +0.9% | Winneshiek +0.6% |
| Brandy | Jefferson +5.9% | Iowa +4.7% | Henry +3.3% | Buchanan +2.6% | Montgomery +2.1% |

Most of the top CAGRs come from **small bases** (often under 5,000 liters in 2025). They're real percentage changes, but a single store opening can produce them, so A3 (volume) is the better guide to where growth matters.

### A6. Same-store growth by county

Only stores that sold in both 2019 and 2025 with at least 11 active months in each year, so openings, closings and partial years don't count as growth or decline. Total liters (all families), CAGR 2019→2025. Unlike A2–A5 this is total volume, not per adult, so it measures change at existing stores.

| Group | Counties | Notes |
|---|---:|---|
| Grew | 15 | Mostly small bases; the largest real gains are **Marshall (+6.7%, 182K → 269K L)**, Palo Alto (+5.0%) and Scott (+1.3%) |
| Flat | 1 | Marion (0.0%) |
| Declined | 81 | Includes Polk (−2.3%), Black Hawk (−2.2%), Story (−2.8%), Dallas (−2.7%), Linn (−1.1%) |

97 counties have at least one qualifying store; Davis and Pocahontas have none.

Selected counties:

| County | Same-store 2019 L | Same-store 2025 L | Same-store CAGR | What it means |
|---|---:|---:|---:|---|
| Marshall | 181,834 | 268,655 | +6.7% | Real growth at existing stores, so Marshall's A2/A4 growth is not just new outlets |
| Scott | 1,008,526 | 1,086,929 | +1.3% | Only large metro where existing stores grew |
| Polk | 4,342,738 | 3,784,472 | −2.3% | Existing Des Moines-area stores lost about 560K liters |
| Clinton | 272,749 | 179,353 | −6.7% | Confirms Headline 4: established stores shrank while one new store grew |
| Fremont | 2,618 | 3,238 | +3.6% | Tiny base; Fremont's high per-adult CAGRs are small-number effects |
| Ringgold | 6,007 | 12,614 | +13.2% | Tops the list only because the 2019 base is small |

### A7. Two kinds of high-volume liquor store

Bottle-size mix (share of bottles, 2025) separates stores that look like they supply bars and restaurants from stores serving home shoppers. The name-based `store_type` rules call both "liquor store".

| Store | <750 ml | 750 ml | 1 L | 1.75 L+ | Profile |
|---|---:|---:|---:|---:|---|
| Wilkie Liquors | 0.8% | 17.1% | 79.1% | 3.1% | Bar-supplier style |
| Happy's Wine & Spirits Wholesale | 0.5% | 23.8% | 75.2% | 0.5% | Bar-supplier style |
| Another Round (DeWitt) | 0.6% | 27.5% | 68.8% | 3.0% | Bar-supplier style |
| Central City 2 | 1.3% | 33.8% | 63.4% | 1.5% | Bar-supplier style |
| Hy-Vee Wine & Spirits #1 (Iowa City) | 4.6% | 37.1% | 52.2% | 6.1% | Mixed |
| Marshall Beer Wine Spirits | 18.4% | 25.2% | 46.3% | 10.1% | Mixed |
| I-80 Liquor (Council Bluffs) | 4.7% | 61.8% | 28.0% | 4.6% | Shopper, 750-heavy |
| Hy-Vee Wine & Spirits (Bettendorf) | 21.8% | 47.3% | 5.6% | 25.2% | Shopper |
| Hy-Vee Wine & Spirits (Ankeny) | 18.6% | 49.7% | 3.3% | 28.3% | Shopper |
| Wall to Wall Wine & Spirits (West Des Moines) | 11.4% | 67.9% | 1.0% | 19.6% | Shopper |

Applying a rule statewide (at least 20,000 L in 2025, at least 50% 1 L bottles, under 3% minis) flags **10 stores selling about 2.3 million liters in 2025, roughly a tenth of statewide volume**:

| Store | County | 2025 liters | 1 L share |
|---|---|---:|---:|
| Hy-Vee #3 / BDI (Des Moines) | Polk | 652,342 | 65.4% |
| Central City 2 | Polk | 616,958 | 63.4% |
| Another Round (DeWitt) | Clinton | 300,970 | 68.8% |
| Benz Distributing | Linn | 253,717 | 62.1% |
| Wilkie Liquors | Linn | 193,998 | 79.1% |
| Happy's Wine & Spirits Wholesale | Black Hawk | 94,428 | 75.2% |
| Madella Wine and Spirits (Bettendorf) | Scott | 74,418 | 73.7% |
| The Boonedocks | Dickinson | 53,477 | 77.1% |
| MMDG Spirits (Ames) | Story | 27,691 | 90.3% |
| AJ's Liquor III | Story | 24,538 | 90.4% |

Hy-Vee #3 / BDI is Iowa's single largest store by volume, and the name rules classify it as a grocery store, which is wrong for its sales mix. The Boonedocks is in the Okoboji tourist area, which helps explain Dickinson's top liters-per-adult ranking. The two Ames stores sit in a college town with many bars.

Bars typically pour well spirits from 1 L bottles, while home shoppers buy minis and 1.75 L handles. Stores that sell mostly to bars put their volume where they sell it, not where it's drunk, which inflates per-adult figures in their county (relevant to Polk and Clinton).

**Final supplier rule and sensitivity**

1 L share has no natural break (it declines gradually from about 90% to under 30% among high-volume stores), so the rule combines three conditions, each with a reason:

- **At least 60% of bottles are 1 L**: the bar-pour size.
- **Under 10% are 1.75 L handles**: excludes warehouse clubs. Sam's Club stores are about 50% 1 L but 35–52% handles, a home bulk-buying mix.
- **Under 10% are minis (under 750 ml)**: excludes convenience stores with mixed customers.
- **At least 20,000 L per active year**, so the mix is stable and the store matters at county level.

This flags 15 stores, the 10 in A7 plus Lot-A-Spirits, Hillstreet News and Tobacco, Sycamore Convenience, Beer on Floyd and Hy-Vee Wine & Spirits #2 (Davenport). The earlier draft rule, which had no handle cap, wrongly flagged Sam's Club Davenport.

**Sensitivity: supplier share of 2025 county volume at a 60% vs 50% 1 L cutoff**

| County | 60% cutoff | 50% cutoff |
|---|---:|---:|
| Clinton | 54.7% | 54.7% |
| Polk | 27.0% | 27.0% |
| Linn | 23.4% | 23.4% |
| Black Hawk | 17.3% | 17.3% |
| Dickinson | 16.5% | 22.9% |
| Story | 8.3% | 8.3% |
| Scott | 5.3% | 7.6% |
| Woodbury | 4.3% | 4.3% |
| Johnson | — | 27.3% |
| Dubuque | — | 5.5% |

The counties that drive the findings (Clinton, Polk, Linn, Black Hawk, Story) are identical at both cutoffs. The one big difference is **Johnson County**: at 50% it picks up Hy-Vee Wine & Spirits #1 in Iowa City (52% 1 L bottles, about 319,000 L a year), a genuinely mixed store in a college town. The 60% rule is used throughout; Johnson's per-adult figures should be described as sensitive to this choice.

### A8. How much the supplier-profile stores change the results

All stores vs "retail" (all stores except the 15 supplier-profile stores flagged by the final rule in A7).

**Their share of volume, by year**

| Year | All liters | Retail liters | Supplier share |
|---|---:|---:|---:|
| 2017 | 21,096,850 | 19,056,694 | 9.7% |
| 2018 | 21,895,982 | 19,800,798 | 9.6% |
| 2019 | 22,301,422 | 20,057,492 | 10.1% |
| 2020 | 24,211,661 | 22,533,848 | **6.9%** |
| 2021 | 24,755,365 | 22,290,290 | 10.0% |
| 2022 | 23,566,096 | 20,908,183 | 11.3% |
| 2023 | 23,728,547 | 20,989,178 | 11.5% |
| 2024 | 23,308,431 | 20,723,687 | 11.1% |
| 2025 | 22,097,898 | 19,689,079 | 10.9% |

- **COVID shows up in the bar-supplier stores.** Their volume fell about 25% in 2020 (2.24M → 1.68M liters) while retail volume rose about 12% (20.06M → 22.53M), which is what bar and restaurant closures plus at-home drinking would produce. They were back to a 10% share in 2021 and have held a slightly larger share (about 11%) since 2022.
- **Retail demand per adult is falling a little faster than the headline:** statewide liters per adult went from 9.82 to 9.48 for all stores (−3.5%) between 2019 and 2025, but from 8.83 to 8.44 for retail only (−4.4%).

**Statewide and typical-county liters per adult**

| Year | Statewide, all | Statewide, retail | County median, all | County median, retail |
|---|---:|---:|---:|---:|
| 2017 | 9.29 | 8.39 | 6.64 | 6.64 |
| 2018 | 9.64 | 8.72 | 6.77 | 6.77 |
| 2019 | 9.82 | 8.83 | 6.76 | 6.76 |
| 2020 | 10.38 | 9.66 | 7.78 | 7.78 |
| 2021 | 10.62 | 9.56 | 7.59 | 7.59 |
| 2022 | 10.11 | 8.97 | 7.06 | 7.06 |
| 2023 | 10.18 | 9.00 | 7.24 | 7.24 |
| 2024 | 10.00 | 8.89 | 7.19 | 7.19 |
| 2025 | 9.48 | 8.44 | 6.87 | 6.87 |

The county median doesn't change at all, which confirms the flag only affects a handful of counties. The statewide figure drops by about 1 liter per adult.

**Family growth, retail only (2019 → 2025).** The headlines hold:

| Family | Retail L/adult 2019 | Retail L/adult 2025 | CAGR, retail | CAGR, all stores |
|---|---:|---:|---:|---:|
| Tequila/Mezcal | 0.31 | 0.45 | **+6.4%** | +5.8% |
| Other | 0.30 | 0.35 | +2.8% | +3.2% |
| RTD/Cocktails | 0.34 | 0.39 | +2.5% | +2.4% |
| Vodka | 2.81 | 2.78 | −0.2% | −0.2% |
| Whiskey | 2.42 | 2.25 | −1.2% | −1.1% |
| Liqueur | 1.10 | 1.00 | −1.6% | −1.2% |
| Rum | 1.03 | 0.85 | −3.3% | −3.1% |
| Gin | 0.22 | 0.17 | −3.8% | −3.2% |
| Brandy | 0.30 | 0.21 | −6.0% | −5.9% |

Tequila grows slightly *faster* among retail stores, so its rise is driven by home shoppers rather than bars. The declining families (liqueur, gin, rum, whiskey) fall a little faster at retail, so bar purchases were cushioning those declines. The ranking of families is identical either way.

**County rankings, 2025** (retail top 10, plus every county with a supplier-profile store; ranks are out of all counties)

| County | L/adult, all | L/adult, retail | Rank, all | Rank, retail | Supplier share |
|---|---:|---:|---:|---:|---:|
| Dickinson | 22.57 | 18.85 | 1 | 1 | 16.5% |
| Cerro Gordo | 15.09 | 15.09 | 3 | 2 | 0.0% |
| Carroll | 12.25 | 12.25 | 5 | 3 | 0.0% |
| Pottawattamie | 11.42 | 11.42 | 6 | 4 | 0.0% |
| Johnson | 11.02 | 11.02 | 9 | 5 | 0.0% |
| Marshall | 10.86 | 10.86 | 11 | 6 | 0.0% |
| Kossuth | 10.51 | 10.51 | 12 | 7 | 0.0% |
| Hardin | 10.45 | 10.45 | 13 | 8 | 0.0% |
| Scott | 10.99 | 10.41 | 10 | 9 | 5.3% |
| Clay | 10.11 | 10.11 | 14 | 10 | 0.0% |
| Woodbury | 10.11 | 9.67 | 15 | 11 | 4.3% |
| Polk | 12.92 | 9.43 | 4 | 15 | 27.0% |
| Black Hawk | 11.04 | 9.13 | 8 | 19 | 17.3% |
| Linn | 11.34 | 8.69 | 7 | 23 | 23.4% |
| Story | 9.37 | 8.60 | 19 | 24 | 8.3% |
| Clinton | 16.00 | 7.25 | 2 | 41 | 54.7% |

- **Clinton** goes from the 2nd-highest county in the state to 41st once Another Round is removed.
- **Polk, Black Hawk and Linn**, the three largest metros after Scott, all fall out of the top 10 (4th → 15th, 8th → 19th, 7th → 23rd). Their supplier stores sell to bars across a wider area than the county's own residents.
- **Dickinson stays 1st** even without The Boonedocks (22.57 → 18.85), so its high rate is mostly tourism at ordinary stores.
- The retail top 10 is mostly regional-center and non-metro counties (Cerro Gordo, Carroll, Kossuth, Hardin, Clay) plus Pottawattamie and Johnson.

### Caveats

- **Sales location, not residence.** Liters are counted where the store is, so tourism (e.g., Dickinson), cross-border shopping and stores that also supply bars can shift a county's numbers.
- **Endpoint sensitivity.** CAGR uses only 2019 and 2025. A 2017 start or a 2017–2019 pre-COVID comparison is a planned robustness check.
- **Small bases.** High CAGRs in small counties (Fremont, Worth, Humboldt) reflect a few thousand liters and can be driven by one store.
- **Category coding.** Some products are filed outside their natural family (Crown Royal flavors under Temporary & Specialty Packages, budget agave spirits under Distilled Spirits Specialty, Member's Mark vodka under Special Order Items). This inflates "Other" and likely understates tequila's growth and whiskey's level (see A1).
- **RTD scope.** Canned cocktails are distributed as beer in Iowa since 2019, so "RTD/Cocktails" here excludes the products behind the national RTD boom.
- **Bar-supplier stores.** About 11% of volume is sold through stores that appear to supply bars; per-adult county figures are reported both with and without them (A8). The flag is inferred from bottle mix, since the data doesn't record buyers.

<!-- ### Checks

Done:

- [x] **Clinton County at store level:** one store that opened in 2020 (Another Round, DeWitt) explains the whole increase (Headline 4).
- [x] **Another Round vs DeWitt Travel Mart:** Another Round opened next door and took most of Travel Mart's liquor sales, but that explains only about a tenth of its volume (Headline 4).
- [x] **Who buys at Another Round:** its bottle mix (69% 1 L, under 1% minis, 3% handles) matches the bar-supplier group in A7, not shopper stores. It also orders more than twice as many bottles per line as other liquor stores (26.2 vs 11.8), though that partly reflects its size.
- [x] **Same-store growth, full-year stores only** (A6).
- [x] **Bar-supplier stores flagged statewide** with a rule tested at two cutoffs (A7), and results rerun with and without them (A8). Headlines hold.
- [x] **The Boonedocks (Dickinson):** bar-like every year (64–77% 1 L); flagged by the final rule.
- [x] **Fremont:** same-store volume is tiny (2,600 → 3,200 L), so its high CAGRs are small-number effects. Not featured as a finding.

Still open (optional before the memo):

- [x] **What drives "Other" statewide:** relabeled whiskey (Crown Royal flavors), budget agave spirits filed as specialty, Member's Mark vodka, holiday packs, flavored moonshine and a little soju (A1).
- [ ] **Did the agave "DSS" products move out of Mixto Tequila?** Check whether Juarez Gold and Tortilla Gold were filed as tequila before 2025; if so, tequila's measured growth is held down by reclassification.
- [ ] **Optional item-level remap:** a small seed (`item_family_overrides.csv`) moving the biggest misfiled items to their natural family, then rerun A1.
- [ ] **Marshall "Other" (+37.5%):** check which products drive it (likely the same items above at one or two stores). Same-store sales also grew (+6.7%), so this is not only a new-store effect.
- [ ] **Store count over time:** count active stores per year to confirm that new outlets grew while existing ones lost volume.
- [ ] **Split the statewide 2019→2025 change** into existing, new and closed stores.
- [ ] **Robustness:** rerun A1 with a 2017 start and compare rankings. -->

---

---

## B. Peer benchmarking: who is under-buying?

<!-- **Run date:** 2026-11-13 -->
**Queries:** `sql/analysis/b_peers.sql` (`marts.store_peers`), `b2_category_gaps.sql` (`marts.store_category_gaps`), `b3_store_investigation.sql` (per-store checks), `b4_store_groups.sql` (group labels)

**Method.** Each store's 2025 purchases are compared with the median of similar stores: same kind of store (full Hy-Vee, Hy-Vee Dollar Fresh, Fareway and independent grocers separately; warehouse clubs separately from Walmart and Target), same size of place (small town under 5,000 people in the store's ZIP area, non-metro town, or metro) and same third of local income. A store is flagged as under-buying when it's below half its peer median in **both liters and dollars**, has sold since at least 2023, and its peer group has at least 10 stores. Bar-supplier stores (A7), catch-all types, producers, bars/hotels and wholesalers are excluded. Dollars are used alongside liters because mini multi-packs understate liters (DQ-24). Stores that opened in 2024 or later are reported separately as new entrants.

### Headlines

1. **Most low-buying stores are explained by something other than missed demand.** Of the 25 lowest flagged stores, 8 reflect a chain's store format, 3 a price position (premium, online or budget), 6 a 2023 opening whose sales fell back after the first full year, and 1 a saturated local market. **7 are candidate under-buyers**; three were checked store by store, and only one of those has a clear, fixable assortment gap.
2. **Crowded markets are a bigger story than under-stocked stores.** Stop and Shop Liquor in Ankeny sells about 15% of what comparable liquor stores sell, but its category mix matches its peers. Its ZIP code (50023) had 21 active liquor licensees in 2025, including 4 liquor stores, and 5 of those licensees opened in 2024–2025. Its sales have fallen every year since opening (2,030 → 1,314 → 1,176 L). In Ames ZIP 50014, five liquor stores opened and closed between 2017 and 2024, and a new one opened in 2025. This is the store-level face of Part A's Headline 5: store counts grow faster than demand, so stores split a flat market.
3. **New stores are common, and many start small.** 22 stores that opened in 2024–2025 sit below half their peers, more than the established stores flagged as candidates. Stores that opened in 2023 mostly peaked in their first full year and fell 10–59% in 2025, partly because purchase data includes the one-time stocking of a new store's shelves.
4. **Tequila is the most widely under-stocked category.** 142 stores sell less than half the tequila share their peers do, more than any other family, about **\$1.1M** in gap at 2025 prices. That matches Part A: the fastest-growing category is also the one most often under-represented. Brandy and liqueur show larger dollar gaps (\$2.0M and \$1.7M), but brandy is shrinking about 6% a year per adult, so its gap is less of an opportunity.

### Final counts (all stores)

Every store in the peer comparison, labeled by `b4_store_groups.sql` (rules, overridden by the manual review in `seeds/store_review.csv`):

| Group | Stores | 2025 $ | Gap to peer median | Gap to half the median |
|---|---:|---:|---:|---:|
| Candidate under-buyers | 68 | 3,010,254 | 4,756,349 | 873,048 |
| Chain format | 32 | 4,437,728 | 9,441,275 | 2,501,774 |
| Post-opening decline (2023 openings) | 18 | 933,135 | 2,657,217 | 862,041 |
| Price position | 4 | 136,742 | 473,078 | 168,168 |
| Saturated market | 1 | 33,843 | 192,774 | 79,466 |
| **Flagged, total** | **123** | | | |
| New entrants (2024–2025, reported separately) | 22 | 984,323 | 1,939,247 | 477,462 |

**For the memo:** 123 established stores buy less than half of what comparable stores buy. 55 of them are explained by chain format, price position, a recent opening or a saturated market. The remaining **68 candidates** would add about **\$0.9M a year** just to reach half their peer median, or up to **\$4.8M** to reach the median itself; the realistic figure is lower, since only 3 candidates were checked and only one had a clear assortment gap. Another 22 stores opened in 2024–2025 and are still below half their peers.

The candidate group is the rule-based remainder, so it's an upper bound: stores not yet reviewed stay in it by default.

### B1. Flagged stores, classified

The 25 lowest flagged stores by dollar ratio, grouped by what explains them. † = checked store by store; the others are classified from peer data, price per liter and opening year.

| Group | Stores | Why | Opportunity? |
|---|---|---|---|
| **Chain format (8)** | Hy-Vee Food Store Denison†; Hy-Vee Perry, Vinton, Winterset; Hy-Vee Fast and Fresh (Johnston); Target Cedar Falls, Fort Dodge; Walmart Tipton | Denison's liquor sales go to the Hy-Vee Wine & Spirits in the same town (38,000 L vs the grocery's 1,800). Perry, Vinton and Winterset are small-city Hy-Vees compared with Des Moines-area ones (a known limit of the town-size cutoff). Hy-Vee Fast and Fresh sells mostly minis (46% of dollars in multi-packs). Target carries a small liquor section by design; Walmart Tipton is likely a smaller-format store (not checked). | No: the chain sets the format |
| **Price position (3)** | Whiskey Business (Allerton)†; Mills Grocery and Liquor (West Des Moines); Tequila Wine & Spirits (Kalona) | Whiskey Business is an online premium seller (\$58/L). Mills sells at about \$41/L, a premium mix. Kalona sells at about \$12.60/L, a budget mix (42% of peers in liters but 23% in dollars). | No: a different business model |
| **Post-opening decline (6)** | Bootleggers (Sioux); Super Quick Liquor (Knoxville); Highway Liquors and Tobacco (Oskaloosa); Kimmes Denison Country Store; Hy-Vee Eldridge; Hy-Vee C-Store #3 (Cedar Rapids) | Opened in 2023. Five peaked in 2024 and fell 10–59% in 2025; Hy-Vee C-Store #3 is still growing but small and mini-heavy (41% of dollars in multi-packs). | Unclear: watch, don't target yet |
| **Saturated market (1)** | Stop and Shop Liquor (Ankeny)† | See Headline 2 and B2. | No: the market is crowded, not under-served |
| **Candidate under-buyers (7)** | Fareway #189 (Ames)†; Three Doors Down Liquor (Whittemore)†; Boyd Grocery (Keosauqua)†; West Forty Market (Greene); Hometown Foods (State Center); Big 10 Mart #11 (Dubuque); Shop n Save (Newton) | 22–26% of true peers in dollars, established before 2023, no obvious format or price explanation. See B2 for the three that were checked. | Partly: one clear assortment gap so far |

### B2. Store case studies

**Stop and Shop Liquor, Ankeny (010082): saturated market**

| | |
|---|---|
| Address | 409 South Ankeny Blvd, Ankeny 50023 (Polk) |
| Opened | December 2022 |
| Liters | 2023: 2,030 · 2024: 1,314 · 2025: 1,176 |
| 2025 vs peers | 12% of median liters, 15% of median dollars (metro liquor stores, n = 43) |
| Category mix | Close to peers; no family flagged (largest gap: tequila 9.2% vs 12.1%, about \$1,000) |
| Same ZIP, 2025 | Hy-Vee Food Store #2 (84,189 L), Liquor Lovers (31,579), Sip & Burn (11,763), seven Casey's, two Maverik, Hy-Vee C-Store and Gas, Tobacco Hut, plus 2024–2025 openings Chamling Smoke & Liquor, Deswan'a Liquor, Subedi LLC and Mega Saver |

The store isn't missing categories; it's a small store in one of the most crowded liquor markets in the state, and new competitors keep arriving. Supports a saturation explanation, not an assortment fix.

**Fareway #189, Ames (5648): candidate with a clear assortment gap**

| | |
|---|---|
| Address | 3720 Lincoln Way, Ames 50014 (Story) |
| Liters | 2019: 3,510 · 2020: 4,743 · 2021–2024: about 2,400–3,200 · 2025: 1,683 (−39%) |
| 2025 vs peers | 26% of median dollars among metro Fareways (n = 19) |
| Category mix | Whiskey-heavy (48.8% vs 40.5% for peers). **Vodka 11.1% vs 22.2%** (gap about \$5,300) and **rum 1.9% vs 9.0%** (about \$3,400), both flagged. Tequila is above peers. |
| Same ZIP | MMDG Spirits (27,524 L, a bar-supplier profile store), Crown Liquor (opened 2025), Maverik, SipN'Smoke (2024), Casey's (2025). Five other liquor stores opened and closed in this ZIP between 2017 and 2024. |

The only checked store with a specific, fixable gap: it carries far less vodka and rum than other Fareways while over-indexing on whiskey. The 2025 drop coincides with a new liquor store opening in the same ZIP, so competition is part of the story too.

**Three Doors Down Liquor, Whittemore (6034): candidate, struggling sole store**

| | |
|---|---|
| Address | 417 Broad St, Whittemore 50598 (Kossuth) |
| Liters | 2021: 2,224 · 2022: 3,149 · 2023: 2,739 · 2024: 2,654 · 2025: 1,338 (−50%) |
| 2025 vs peers | 23% of median dollars (small-town liquor stores, n = 11) |
| Ordering | Erratic since 2025: several months with almost no orders (about 2 L in Aug and Nov 2025, Jan and Apr 2026) |
| Category mix | Vodka 8.9% vs 19.1% (gap about \$2,400, flagged); rum and brandy above peers |
| Same ZIP | No other active store (the only other licensee closed in 2018) |

The only liquor outlet in its town, with a sharp 2025 decline and gaps in ordering. That pattern looks more like reduced operations (hours, staffing or ownership) than lost demand; the vodka gap is real but small.

**Boyd Grocery, Keosauqua (4130): candidate, stable then stepped down**

| | |
|---|---|
| Address | 20611 Hwy 1 N, Keosauqua 52565 (Van Buren) |
| Liters | 2017–2023: steady at about 2,400–2,800 · 2024: 1,767 · 2025: 1,589 |
| 2025 vs peers | 24% of median dollars (small-town independent grocers, n = 24) |
| Category mix | Vodka-heavy (40.0% vs 21.2%), lowest price per liter on the list (\$11.90); no family flagged |
| Same ZIP | Circle B Market (5,405 L) |

Long-established and steady until a step down in 2024. No category gaps; the store is simply small, with a budget vodka-heavy mix. Not an assortment opportunity.

**Data notes from these checks:** Liquor Lovers (Ankeny) appears under two store numbers (010039 in 2022–2023, then 010270), and Crown Liquor (Ames) under two numbers in 2025 (010600 and 010713). Store numbers can change with a license or ownership change, which can make an existing store look new.

### B3. Category gaps

Each store's family share of dollars vs the median share among its peers. Gap = the extra dollars the store would sell if its mix matched its peers at its current size; flagged when the store sells under half the expected amount and at least \$2,000 is expected.

| Family | Stores with a gap | Gap, 2025 $ |
|---|---:|---:|
| Brandy | 121 | 1,959,298 |
| Liqueur | 73 | 1,697,243 |
| Tequila/Mezcal | 142 | 1,144,626 |
| Whiskey | 23 | 815,913 |
| Rum | 103 | 549,149 |
| Vodka | 22 | 305,049 |
| RTD/Cocktails | 47 | 262,975 |
| Gin | 32 | 92,013 |

**Largest tequila gaps (top 10):**

| Store | County | Type | Tequila $ | Expected $ | Gap $ | Share | Peer share |
|---|---|---|---:|---:|---:|---:|---:|
| John's Grocery | Johnson | grocery | 69,539 | 202,094 | 132,555 | 8.6% | 25.0% |
| Wines and Spirits | Washington | liquor store | 61,504 | 130,535 | 69,032 | 8.7% | 18.4% |
| Hy-Vee Drugstore #5 (Cedar Rapids) | Linn | pharmacy | 26,851 | 85,259 | 58,408 | 2.9% | 9.3% |
| Hy-Vee Wine and Spirits | Washington | liquor store | 17,153 | 68,567 | 51,414 | 4.6% | 18.4% |
| Hy-Vee Wine and Spirits (Algona) | Kossuth | liquor store | 24,768 | 74,675 | 49,906 | 3.0% | 9.2% |
| AJ's Liquor II | Story | liquor store | 28,121 | 73,249 | 45,129 | 7.1% | 18.4% |
| Hy-Vee Drugtown #1 (Cedar Rapids) | Linn | pharmacy | 22,146 | 61,886 | 39,740 | 4.0% | 11.2% |
| Pit Stop Liquors (Newton) | Jasper | liquor store | 4,159 | 34,025 | 29,866 | 2.2% | 18.4% |
| Walmart (Waverly) | Bremer | big box | 23,204 | 51,680 | 28,476 | 5.1% | 11.3% |
| Double D Liquor Store (Waukon) | Allamakee | liquor store | 6,558 | 33,060 | 26,503 | 1.8% | 9.2% |

- **Top row is a bit misleading.** The metro independent-grocery peer group is small (about 10 stores) and its median tequila share is 25%, likely because it includes Hispanic markets where tequila is a core category. John's Grocery is a specialty grocer, so its "gap" mostly reflects who its peers are. Small peer groups with mixed sub-types produce misleading share medians.
- **Four Hy-Vee drugstores in Cedar Rapids** all under-index on tequila, which points to a chain assortment decision rather than four separate store problems.
- **Washington County liquor stores** (Wines and Spirits, Hy-Vee Wine and Spirits) are both well below the 18.4% peer share, a local pattern worth a closer look.

**Small overall AND under-stocking tequila:** with the Dollar Fresh stores now in their own group, the list is short and the gaps small: S & S Meats and Spirits (Osage, about \$5,500), Smokin' Joe's #03 (Clinton, about \$4,300), two 2023 openings (Oskaloosa and Knoxville, about \$2,800–3,200) and six convenience stores under \$2,500 each. Tequila gaps are widespread but mostly sit in stores that aren't otherwise small.

### Caveats

- **Purchases, not retail sales.** The data records what stores buy from the state. Stocking up, initial inventory and multi-packs all shift purchases away from what customers bought.
- **One year.** Flags use 2025 only; an unusual year looks the same as a store that's always low. Averaging 2024–2025 would be more stable.
- **Peer groups are approximations.** Small groups and mixed sub-types (Hispanic markets among independent grocers, small-city Hy-Vees among metro ones) move the medians. Stores in groups under 10 can't be flagged (all Hy-Vee Dollar Fresh stores, most small-town Hy-Vee and Fareway stores, pharmacies, tobacco shops and warehouse clubs).
- **Gaps are upper bounds.** A store may stock little of a category because its customers don't buy it. Summing gaps across stores overstates the realistic opportunity.

<!-- ### Checks

Done:

- [x] Peer groups rebuilt: Hy-Vee, Hy-Vee Dollar Fresh, Fareway and independent grocers separate; warehouse clubs separate; town size from ZIP population; bar suppliers and catch-all types excluded.
- [x] Flags require low liters AND low dollars (multi-pack liters understated, DQ-24).
- [x] New-store rule tested: 2023 openings aren't still ramping up (most fell in 2025), so stores open since 2023 or earlier can be flagged; 2024+ openings are reported separately.
- [x] Store-level checks: Hy-Vee Denison (chain split), Whiskey Business (online premium), Stop and Shop Liquor (saturated market), Fareway #189 (vodka/rum gap plus new competitor), Three Doors Down (erratic ordering, sole store), Boyd Grocery (step-down, no gap).

To finish Part B:

- [x] Group labels added to `marts.store_peers` (`b4_store_groups.sql`); final counts recorded above.
- [x] Add `marts.store_peers` (with the group label) to the Power BI model for the store benchmarking page. -->

Possible follow-up questions:

- Is market saturation measurable? Licensees per 1,000 adults by ZIP vs sales per store, to test whether crowded ZIPs have lower same-store sales.
- How often do store numbers change across license or ownership changes (Liquor Lovers, Crown Liquor), and does linking them change any new-store or same-store results?
- Should independent grocers be split into Hispanic markets and others, and does that remove the large tequila "gaps"?
- Do the flags hold with a 2024–2025 average instead of 2025 alone?
- With geocoded addresses, does distance to the nearest competitor explain under-buying better than ZIP?
- Why does Washington County under-index on tequila?
- What explains the 2024–2025 step-downs at long-established stores like Boyd Grocery and Three Doors Down?

---

## C. COVID: what changed, and did it last?

<!-- **Run date:** 2026-11-13 -->
**Queries:** `sql/analysis/c1_covid_index.sql` (`marts.covid_monthly`), `c2_covid_mix.sql`

**Method.** Each month's liters are indexed against the average of the same calendar month in the pre-COVID baseline (March 2018 – February 2020), so 100 means "a normal month for that time of year" and holiday seasonality cancels out. The index is built three times: all stores, retail stores, and the 15 bar-supplier-profile stores from A7, which are the closest thing this data has to bar and restaurant demand. Periods: COVID year (March 2020 – February 2021), transition (March – December 2021), recovery (2022 onward).

### Headlines

1. **COVID split the market in two.** In April 2020, with Iowa's bars and restaurants closed, bar-supplier stores bought **86% less** than a normal April (index 14) while retail stores bought **24% more** (124). Over the first COVID year, retail averaged **115** and bar suppliers **76**; total purchases still rose to 111 because the at-home gain was larger than the bar loss.
2. **The bar-supplier line tracks the state's restrictions month by month.** It fell to 67 in March 2020 (bars closed March 17), bottomed at 14 in April and 35 in May, and was back to 98 in June after bars reopened on May 28. It dipped again to 85–87 in August–September, when bars in six counties (Polk, Linn, Johnson, Story, Dallas and Black Hawk, where most supplier-profile stores are) were closed from August 27 until September 16 (October 5 in Johnson and Story), and recovered to 98 in October. It fell to 72 in November–December 2020 under new distancing rules for bars and restaurants from November 12, and climbed back after normal hours resumed on December 17.
3. **The at-home surge didn't last; the bar side came back strong.** Retail fell from 113 (2020) to 99 (2025), back at its pre-COVID level. Bar suppliers rebounded to 112 in 2021 and peaked at 125 in 2023, and were still at 110 in 2025. Part of that rise is new supplier stores rather than more demand per store (Another Round opened in 2020), so it should be read as the on-premise channel's share recovering and growing, not as bars selling a third more.
4. **The one category COVID really boosted was RTD/cocktails, and it gave most of it back.** Its share of liters rose from 3.5% to 5.2% in the COVID year (ready-to-drink cocktails for home), then fell to 4.0%. Tequila's share rose in every period (4.1% → 4.5% → 5.9%), so its growth is a longer trend, not a COVID effect, which matches Part A.

### C1. Monthly index, March 2020 – June 2021 (100 = normal month)

| Month | All | Retail | Bar suppliers | Note |
|---|---:|---:|---:|---|
| 2020-02 | 98 | 98 | 105 | Pre-COVID |
| 2020-03 | 121 | 128 | 67 | Bars closed March 17; stocking up |
| 2020-04 | 112 | 124 | **14** | Lowest month for bar suppliers |
| 2020-05 | 98 | 104 | 35 | Bars reopen May 28 at 50% capacity |
| 2020-06 | 118 | 120 | 98 | |
| 2020-07 | 111 | 113 | 95 | |
| 2020-08 | 106 | 109 | 85 | Bars closed in six counties from Aug 27 |
| 2020-09 | 133 | 138 | 87 | Reopened Sept 16 in four counties; Johnson and Story stay closed |
| 2020-10 | 100 | 101 | 98 | Johnson and Story reopen Oct 5 |
| 2020-11 | 103 | 107 | 72 | Distancing rules for bars and restaurants from Nov 12 |
| 2020-12 | 113 | 117 | 72 | Normal hours resume Dec 17 |
| 2021-01 | 110 | 113 | 89 | |
| 2021-02 | 107 | 109 | 93 | |
| 2021-03 | 131 | 133 | 119 | Bar side back above normal |
| 2021-06 | 120 | 119 | 129 | |

Month-to-month swings of about ±10 points are normal in this data (ordering days per month vary), so single months matter less than runs of months.

### C2. Average index by period and by year

| Period | All | Retail | Bar suppliers |
|---|---:|---:|---:|
| Baseline (to Feb 2020) | 98.2 | 98.4 | 97.2 |
| COVID year (Mar 2020 – Feb 2021) | 111.1 | **115.1** | **75.5** |
| Transition (Mar – Dec 2021) | 113.0 | 112.7 | 116.6 |
| Recovery (2022 on) | 103.6 | 102.3 | 116.4 |

| Year | All | Retail | Bar suppliers |
|---|---:|---:|---:|
| 2019 | 100.7 | 100.5 | 102.2 |
| 2020 | 109.5 | 113.1 | 77.5 |
| 2021 | 112.3 | 112.3 | 112.4 |
| 2022 | 106.5 | 104.9 | 121.2 |
| 2023 | 107.6 | 105.7 | 125.1 |
| 2024 | 105.6 | 104.3 | 117.8 |
| 2025 | 100.2 | 99.1 | 110.0 |

The "baseline" period label covers every month before March 2020 (from 2017), while the index is built on March 2018 – February 2020 only, so it averages slightly under 100.

### C3. Category mix by period (share of liters)

| Family | Baseline | COVID year | Recovery | Change |
|---|---:|---:|---:|---|
| Vodka | 31.8% | 30.5% | 31.8% | Dipped, recovered |
| Whiskey | 26.7% | 26.7% | 26.1% | Stable |
| Liqueur | 13.3% | 12.6% | 12.9% | Stable |
| Rum | 12.0% | 11.2% | 10.4% | Steady decline |
| Tequila/Mezcal | 4.1% | 4.5% | **5.9%** | Rising throughout |
| RTD/Cocktails | 3.5% | **5.2%** | 4.0% | COVID spike, mostly reversed |
| Other | 3.1% | 3.5% | 4.2% | Rising, mostly misfiled whiskey and agave products (see A1) |
| Brandy | 3.1% | 3.3% | 2.4% | Small COVID bump, then decline |
| Gin | 2.5% | 2.3% | 2.2% | Steady decline |

Average bottle size by family isn't reported: mini multi-packs (DQ-24) are counted as single 50 ml bottles, so the apparent shrinking of liqueur bottles (588 → 395 ml) mostly reflects more Fireball and 99 Brand multi-packs, not smaller bottles.

### Caveats

- **Purchases, not consumption.** March 2020 includes stores stocking up, and the bar-supplier series measures what those stores bought, which is a proxy for on-premise demand rather than a direct measure.
- **Supplier group membership is fixed across years.** The 15 stores are defined from their bottle mix over all years, including Another Round, which opened in 2020. The post-2021 rise mixes new stores with growth at existing ones; a same-store version of the index would separate them.
- **Liters, not dollars.** Multi-pack liters are understated (DQ-24); if the multi-pack share changed over time, the retail index is slightly affected.

<!-- ### Checks

- [x] Index by segment, period averages, yearly averages and category mix by period.
- [x] Restriction dates checked against the governor's proclamations and Ballotpedia's Iowa timeline: statewide closure March 17, 2020; bars reopen May 28 (50% capacity); six-county bar closure August 27; reopening September 16 (Black Hawk, Dallas, Linn, Polk) and October 5 (Johnson, Story); distancing rules from November 12; normal hours from December 17. -->

Possible follow-up questions:

- Rerun C2 by store type: did convenience stores or grocers gain share during COVID?
- A same-store version of the bar-supplier index (stores open in both 2019 and 2023) to separate new-store growth from recovery.
- Was the March 2020 spike stocking up (a one-month surge followed by a dip) or sustained higher demand? Weekly data would show it.


<!-- # A Growth: where is demand rising?
### a1
|family|lpa_2019|lpa_2025|cagr|
|------|--------|--------|----|
|Tequila/Mezcal|0.41064585007209130832|0.57475429538674777125|0.05763495990358017228|
|Other|0.33676394774205619820|0.40739522704309624651|0.03224247152706581037|
|RTD/Cocktails|0.34485407618565437996|0.39699611759822009054|0.02374505260382155119|
|Vodka|3.1061654996312887|3.07391129142929680196|-0.00173819095245947544|
|Whiskey|2.6114086223406012|2.44743197541474326316|-0.01075021169217157711|
|Liqueur|1.3032426120166856|1.20895793771689215732|-0.01243811513249364974|
|Rum|1.1532497617134618|0.95285404991157061228|-0.03131218885554358597|
|Gin|0.24421414310399859119|0.20113111779549224549|-0.03183047272506263023|
|Brandy|0.30770703413055680905|0.21330715832033910226|-0.05924182493846088639|


### a2

|family|rank_in_family|county|lpa_2019|lpa_2025|cagr_pct|liters_2025|
|------|--------------|------|--------|--------|--------|-----------|
|Brandy|1|JEFFERSON|0.09|0.13|5.9|1660|
|Brandy|2|IOWA|0.27|0.36|4.7|4376|
|Brandy|3|HENRY|0.17|0.20|3.3|3036|
|Brandy|4|BUCHANAN|0.08|0.09|2.6|1365|
|Brandy|5|MONTGOMERY|0.13|0.15|2.1|1142|
|Gin|1|CLARKE|0.16|0.28|10.2|1905|
|Gin|2|CLINTON|0.18|0.32|9.6|10911|
|Gin|3|DALLAS|0.24|0.27|2.0|20870|
|Gin|4|JEFFERSON|0.12|0.12|0.9|1544|
|Gin|5|WINNESHIEK|0.26|0.27|0.6|3930|
|Liqueur|1|FREMONT|0.08|0.30|24.2|1471|
|Liqueur|2|WORTH|0.38|0.79|12.8|4488|
|Liqueur|3|CLINTON|1.47|2.93|12.1|100490|
|Liqueur|4|ADAMS|0.46|0.84|10.8|2267|
|Liqueur|5|AUDUBON|0.26|0.38|6.7|1636|
|Other|1|MARSHALL|0.25|1.69|37.5|48143|
|Other|2|HUMBOLDT|0.09|0.47|32.7|3303|
|Other|3|WORTH|0.06|0.26|26.2|1460|
|Other|4|GUTHRIE|0.03|0.13|25.3|1043|
|Other|5|HANCOCK|0.04|0.14|25.2|1140|
|RTD/Cocktails|1|ALLAMAKEE|0.11|0.27|16.6|2785|
|RTD/Cocktails|2|MARSHALL|0.28|0.57|12.2|16108|
|RTD/Cocktails|3|CLARKE|0.30|0.49|8.6|3335|
|RTD/Cocktails|4|WASHINGTON|0.17|0.26|7.7|4333|
|RTD/Cocktails|5|SHELBY|0.21|0.32|7.5|2749|
|Rum|1|CLINTON|1.21|1.88|7.6|64604|
|Rum|2|JACKSON|0.69|1.02|6.6|14900|
|Rum|3|WAYNE|0.28|0.37|4.6|1722|
|Rum|4|CLAYTON|0.51|0.55|1.4|7043|
|Rum|5|WORTH|0.64|0.68|1.0|3867|
|Tequila/Mezcal|1|CLINTON|0.47|1.35|19.3|46432|
|Tequila/Mezcal|2|MARSHALL|0.28|0.75|17.7|21334|
|Tequila/Mezcal|3|BENTON|0.04|0.11|16.6|2078|
|Tequila/Mezcal|4|JACKSON|0.09|0.20|14.0|2856|
|Tequila/Mezcal|5|GREENE|0.10|0.21|13.3|1380|
|Vodka|1|FREMONT|0.32|0.78|16.4|3900|
|Vodka|2|CLINTON|2.82|4.88|9.5|167524|
|Vodka|3|JEFFERSON|1.53|2.45|8.2|30839|
|Vodka|4|RINGGOLD|0.90|1.34|6.9|4526|
|Vodka|5|VAN BUREN|0.73|1.08|6.6|5705|
|Whiskey|1|FREMONT|0.22|0.69|20.7|3432|
|Whiskey|2|CLINTON|1.86|3.55|11.4|121948|
|Whiskey|3|RINGGOLD|1.13|1.56|5.6|5299|
|Whiskey|4|WAYNE|0.82|1.08|4.7|5043|
|Whiskey|5|DECATUR|0.62|0.81|4.5|4421|

|county|family|cagr_pct|added_liters|liters_2025|
|------|------|--------|------------|-----------|
|POLK|Tequila/Mezcal|4.9|102953|410369|
|CLINTON|Vodka|9.5|70531|167524|
|CLINTON|Whiskey|11.4|58081|121948|
|CLINTON|Liqueur|12.1|49985|100490|
|MARSHALL|Other|37.5|41026|48143|
|LINN|Tequila/Mezcal|7.3|40295|116627|
|POLK|RTD/Cocktails|2.9|31958|200720|
|SCOTT|Tequila/Mezcal|5.3|30547|115290|
|CLINTON|Tequila/Mezcal|19.3|30327|46432|
|POLK|Other|2.6|28688|201943|
|POTTAWATTAMIE|Other|10.1|25437|57882|
|BLACK HAWK|Tequila/Mezcal|6.0|24275|82707|
|CLINTON|Rum|7.6|23035|64604|
|SCOTT|RTD/Cocktails|5.1|20376|78609|
|CERRO GORDO|Vodka|1.7|16587|170020|

|county|top10_families|avg_cagr_pct|
|------|--------------|------------|
|CLINTON|7|9.3|
|MARSHALL|6|7.6|
|JEFFERSON|5|5.3|
|RINGGOLD|4|4.8|
|BENTON|4|3.8|
|JACKSON|4|3.8|
|FREMONT|3|20.4|
|WORTH|3|9.1|
|CLARKE|3|3.6|
|DALLAS|3|3.5|
|HENRY|3|2.5|
|WASHINGTON|3|1.4|

|family|counties|min_pct|median_pct|max_pct|
|------|--------|-------|----------|-------|
|Tequila/Mezcal|76|-13.6|4.6|19.3|
|Other|78|-7.8|4.4|37.5|
|RTD/Cocktails|78|-7.4|2.0|16.6|
|Vodka|99|-6.2|0.9|16.4|
|Liqueur|98|-9.6|-0.8|24.2|
|Whiskey|99|-6.1|-1.3|20.7|
|Rum|95|-11.2|-2.9|7.6|
|Gin|48|-8.2|-4.2|10.2|
|Brandy|57|-13.1|-4.9|5.9| -->